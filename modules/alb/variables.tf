variable "tags" {
  description = "A map of resource tags for the module"
  type = map
}

variable "name" {
  description = "a name for the ALB"
  type = string
}

variable "vpc_name" {
  description = "the VPC name where the ALB will be deployed"
  type = string
}

variable "vpc_id" {
  description = "the VPC ID where the ALB will be deployed"
  type = string
}

variable "vpc_subnets" {
  description = "a list of public subnets where the ALB will be deployed to"
  type = list
}

variable "backend_sg_id" {
  description = "the backend Security Group of the associated ECS cluster"
  type = string
}

variable "alb_ssl_cert_filename" {
  description = "the filename of the ALB SSL cert"
  type = string
}

variable "alb_ssl_key_filename" {
  description = "the filename of the ALB SSL key"
  type = string
}

