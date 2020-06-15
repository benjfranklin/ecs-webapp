# Module to create AWS Global Accelerator

terraform {
  required_version = ">= 0.12"
}

resource "aws_globalaccelerator_accelerator" "alb" {
  name            = "${var.vpc_name}-${var.name}-global-accelerator"
  ip_address_type = "IPV4"
  enabled         = true

}

resource "aws_globalaccelerator_endpoint_group" "alb" {
  listener_arn = aws_globalaccelerator_listener.alb.id
  health_check_path = "/"
  health_check_port = var.alb_port


  endpoint_configuration {
    endpoint_id = var.alb_arn
    weight      = 100
  }
}

resource "aws_globalaccelerator_listener" "alb" {
  accelerator_arn = aws_globalaccelerator_accelerator.alb.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = var.alb_port
    to_port   = var.alb_port
  }
}