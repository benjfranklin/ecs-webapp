terraform {
  required_version = ">= 0.12"
}

resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Security Group managed by Terraform"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "alb_ingress_permit_https_any" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_ingress_permit_http_any" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress_permit_tcp_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ecs_instance_ingress_permit_alb" {
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = var.backend_sg_id
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket_name
  acl    = "private"

  tags        = var.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "${var.name}-alb"

  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  subnets         = var.vpc_subnets
  security_groups = [aws_security_group.alb.id]

  # Currently disabled: https://github.com/terraform-providers/terraform-provider-aws/issues/7987
  /* access_logs = {
    bucket = var.log_bucket_name
  } */

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

 /*  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ] */

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = var.tags
}


resource "aws_globalaccelerator_accelerator" "alb" {
  name            = "test"
  ip_address_type = "IPV4"
  enabled         = true

  /* attributes {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = "example-bucket"
    flow_logs_s3_prefix = "flow-logs/"
  } */
}

resource "aws_globalaccelerator_endpoint_group" "alb" {
  listener_arn = aws_globalaccelerator_listener.alb.id
  health_check_path = "/"
  health_check_port = 80


  endpoint_configuration {
    endpoint_id = module.alb.this_lb_arn
    weight      = 100
  }
}

resource "aws_globalaccelerator_listener" "alb" {
  accelerator_arn = aws_globalaccelerator_accelerator.alb.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}