module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 2.38.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = merge(var.tags, map("service","vpc"))

}

module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  name        = var.ecs_cluster_name
  vpc_id      = module.vpc.vpc_id
  vpc_subnets = module.vpc.private_subnets

  tags = merge(var.tags, map("service","ecs"))
}

module "alb" {
  source = "./modules/alb"

  name                     = var.alb_name
  #host_name                = "app"
  #domain_name              = "example.com"
  #certificate_arn          = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
  #create_log_bucket        = true
  #enable_logging           = true
  #force_destroy_log_bucket = true
  log_bucket_name          = "${var.alb_name}-logs"

  vpc_id      = module.vpc.vpc_id
  vpc_subnets = module.vpc.public_subnets
  backend_sg_id = module.ecs_cluster.instance_sg_id

  tags = merge(var.tags, map("service","alb"))
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
    "image": "776475658441.dkr.ecr.eu-west-2.amazonaws.com/checkout:latest",
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
        "awslogs-region": "eu-west-2"
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
  alb_target_group_arn = module.alb.target_group_arns[0]
  cluster              = module.ecs_cluster.cluster_id
  container_name       = "nginx"
  container_port       = "80"
  log_groups           = ["ecs-alb-single-svc-nginx"]
  task_definition_arn  = aws_ecs_task_definition.app.arn

  tags = merge(var.tags, map("service","app"))
}

