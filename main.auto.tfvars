tags = {
  environment = "dev"
}

region = "eu-west-2"

application_name = "blm"

vpc_name            = "devops-lab"
vpc_cidr            = "10.0.0.0/16"
vpc_azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
vpc_private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
vpc_public_subnets  = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

ecs_cluster_name = "alpha"
alb_name         = "bravo"

