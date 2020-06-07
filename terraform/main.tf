module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.38.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = merge(var.tags, map("service", "vpc"))

}

module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  name        = var.ecs_cluster_name
  vpc_id      = module.vpc.vpc_id
  vpc_subnets = module.vpc.private_subnets

  tags = merge(var.tags, map("service", "ecs"))
}

resource "aws_iam_server_certificate" "alb" {
  name             = "${var.alb_name}-ssl-certificate"
  certificate_body = file("./ssl/${var.alb_ssl_cert_filename}")
  private_key      = file("./ssl/${var.alb_ssl_key_filename}")
}

module "alb" {
  source = "./modules/alb-2"

  name                = var.alb_name
  ssl_certificate_arn = aws_iam_server_certificate.alb.arn
  vpc_id              = module.vpc.vpc_id
  vpc_subnets         = module.vpc.public_subnets
  backend_sg_id       = module.ecs_cluster.instance_sg_id

  tags = merge(var.tags, map("service", "alb"))
}

output "Application_Endpoint_URL" {
  value = "http://${module.alb.accelerator_dns_name}"
}

resource "aws_ecs_task_definition" "app" {
  family = "ecs-alb-single-svc"

  container_definitions = <<EOF
[
  {
    "name": "nginx",
    "image": "nginx:1.13-alpine",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "ecs-alb-single-svc-nginx",
        "awslogs-region": "${var.region}"
      }
    },
    "memory": 128,
    "cpu": 100
  }
]
EOF
}


module "ecs_service_app" {
  source = "./modules/service"

  name                 = "checkout-lab-app"
  alb_target_group_arn = module.alb.target_group_arn
  cluster              = module.ecs_cluster.cluster_id
  container_name       = "nginx"
  container_port       = "80"
  log_groups           = ["ecs-alb-single-svc-nginx"]
  task_definition_arn  = aws_ecs_task_definition.app.arn

  tags = merge(var.tags, map("service","app"))
}

