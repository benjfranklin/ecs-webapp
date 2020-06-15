# Module to create Application Load Balancer

terraform {
  required_version = ">= 0.12"
}

resource "aws_security_group" "alb" {
  name        = "${var.vpc_name}-${var.name}-alb-sg"
  description = "Security Group managed by Terraform"
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "alb_ingress_permit_https_any" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
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

resource "aws_lb" "alb" {
  name               = "${var.vpc_name}-${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.vpc_subnets

  enable_deletion_protection = false

  tags = var.tags
}

resource "aws_lb_target_group" "default" {
  name        = "${var.vpc_name}-${var.name}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  depends_on = [aws_lb.alb]
}

resource "aws_iam_server_certificate" "alb" {
  name             = "${var.vpc_name}-${var.name}-ssl-certificate"
  certificate_body = file("./ssl/${var.alb_ssl_cert_filename}")
  private_key      = file("./ssl/${var.alb_ssl_key_filename}")
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_iam_server_certificate.alb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}
