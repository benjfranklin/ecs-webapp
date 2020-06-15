variable "tags" {
  description = "A map of resource tags for the module"
  type = map
}

variable "cluster_arn" {
  description = "the ARN of the ECS cluster where the service will be deployed"
  type = string
}

variable "alb_target_group_arn" {
  description = "the Target Group ARN of the Application Load Balancer"
  type = string
}

variable "region" {
  description = "the region where the service will be deployed"
  type = string
}

variable "service_name" {
  description = "a descriptive name for the service"
  type = string
}

variable "service_count" {
  description = "the desired number of service instances"
  type = string
  default = 1
}

variable "service_cpu" {
  description = "the amount of CPU to allocate to each service"
  type = string
  default = 100
}


variable "service_memory" {
  description = "the amount of Memory to allocate to each service"
  type = string
  default = 128
}

variable "service_port" {
  description = "the listening port of the service"
  type = string
  default = 80
}

variable "container_url" {
  description = "the container repository URL"
  type = string
}

variable "container_tag" {
  description = "the container tag"
  type = string
  default = "latest"
}


variable "deployment_maximum_percent" {
  type = string
  default = 200
}

variable "deployment_minimum_healthy_percent" {
  type = string
  default = 100
}



