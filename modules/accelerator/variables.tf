variable "tags" {
  description = "a map of resource tags for the module"
  type = map
}

variable "name" {
  description = "a name for the global accelerator"
  type = string
}

variable "vpc_name" {
  description = "the vpc name where the global accelerator will be deployed"
  type = string
}

variable "alb_arn" {
  description = "the ARN of the  Application Load Balancer"
  type = string
}

variable "alb_port" {
  description = "the listener port of the Application Load Balancer"
  type = string
  default = 443
}