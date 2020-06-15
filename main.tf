# Terraform infrastructure code to create a ECS-hosted web application in AWS ECS

terraform {
  required_version = ">= 0.12"
}


# Create an AWS Virtual Private Cloud (VPC)

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.39.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = merge(var.tags, map("service", "vpc"))

}

# Create an AWS Elastic Container Service (ECS) cluter

module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  name        = var.ecs_cluster_name
  vpc_name    = module.vpc.name
  vpc_id      = module.vpc.vpc_id
  vpc_subnets = module.vpc.private_subnets

  tags = merge(var.tags, map("service", "ecs"))
}

# Create an AWS Application Load Balancer (ALB) to front the ECS service

module "alb" {
  source = "./modules/alb"

  name                  = var.alb_name
  vpc_name              = module.vpc.name
  vpc_id                = module.vpc.vpc_id
  vpc_subnets           = module.vpc.public_subnets
  backend_sg_id         = module.ecs_cluster.instance_sg_id
  alb_ssl_cert_filename = var.alb_ssl_cert_filename
  alb_ssl_key_filename  = var.alb_ssl_key_filename

  tags = merge(var.tags, map("service", "alb"))
}

# Create an AWS Elastic Container Registry to host the web-app container image

module "ecr" {
  source               = "./modules/ecr"
  name                 = var.application_name

  tags = merge(var.tags, map("service", "ecr"))
}

# Authenticate local Docker engine to AWS ECR to push container images

resource "null_resource" "docker_login" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --no-verify-ssl | docker login --username AWS --password-stdin ${module.ecr.repository_url}"
  }
}

# Build the Docker container image from source and push to AWS ECR repository

resource "null_resource" "docker_build_push" {
  provisioner "local-exec" {
    command     = "./build.sh ./src ${var.docker_image_name} ${module.ecr.repository_url} ${var.docker_image_tag}"
    interpreter = ["bash", "-c"]
  }

  depends_on = [null_resource.docker_login]
}

# Create an AWS ECS Task Definition and Service for the web-app

module "ecs_service" {
  source = "./modules/ecs-service/"

  service_name   = var.docker_image_name
  service_count  = 3
  container_url = module.ecr.repository_url
  container_tag = var.docker_image_tag

  region               = var.region
  cluster_arn          = module.ecs_cluster.cluster_id
  alb_target_group_arn = module.alb.target_group_arn

  tags = merge(var.tags, map("service", "ecs"))

}

# Create an AWS Global Accelerator to make the ECS-hosted web-app publically accessible

module "accelerator" {
  source = "./modules/accelerator"

  name     = var.alb_name
  vpc_name = module.vpc.name
  alb_arn  = module.alb.alb_arn

  tags = merge(var.tags, map("service", "accelerator"))
}


# Output the application endpoint URL to the console

output "Application_Endpoint_URL" {
  value = "https://${module.accelerator.accelerator_dns_name}"
}
