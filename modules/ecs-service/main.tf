# Module to create AWS ECS task definition and service

terraform {
  required_version = ">= 0.12"
}

resource "aws_cloudwatch_log_group" "service" {
  name  = "ecs-alb-single-svc-${var.service_name}"
  tags = var.tags
}

resource "aws_ecs_task_definition" "service" {
  family = "ecs-alb-single-svc"

  container_definitions = <<EOF
[
  {
    "name": "${var.service_name}",
    "image": "${var.container_url}:${var.container_tag}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.service_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "ecs-alb-single-svc-${var.service_name}",
        "awslogs-region": "${var.region}"
      }
    },
    "memory": ${var.service_memory},
    "cpu": ${var.service_cpu}
  }
]
EOF
}

resource "aws_iam_role" "service" {
  name = "${var.service_name}-ecs-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
	{
	  "Sid": "",
	  "Effect": "Allow",
	  "Principal": {
		"Service": "ecs.amazonaws.com"
	  },
	  "Action": "sts:AssumeRole"
	}
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = aws_iam_role.service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.service_count
  iam_role        = aws_iam_role.service.arn

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.service_name
    container_port   = var.service_port
  }
}