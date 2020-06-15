variable "tags" {
  description = "A map of resource tags for the module"
  type = map
}

variable "name" {
  description = "a name for the ECS cluster"
  type = string
}
variable "vpc_name" {
  description = "the name of the VPC where the ECS cluster will be deployed"
  type = string
}

variable "vpc_id" {
  description = "the ID of the VPC where the ECS cluster will be deployed"
  type = string
}

variable "vpc_subnets" {
  description = "List of private VPC subnets where the ECS cluster will be deployed"
  type = list
  default     = []
}
variable "additional_user_data_script" {
  description = "Additional user data script"
  type = string
  default     = ""
}

variable "asg_max_size" {
  description = "Maximum number EC2 instances"
  type = string
  default     = 3
}

variable "asg_min_size" {
  description = "Minimum number of instances"
  type = string
  default     = 1
}

variable "asg_desired_size" {
  description = "Desired number of instances"
  type = string
  default     = 1
}

variable "image_id" {
  description = "AMI image_id for ECS instance"
  type = string
  default     = ""
}

variable "instance_keypair" {
  description = "Instance keypair name"
  type = string
  default     = ""
}

variable "instance_log_group" {
  description = "Instance log group in CloudWatch Logs"
  type = string
  default     = ""
}

variable "instance_root_volume_size" {
  description = "Root volume size"
  type = string
  default     = 50
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default     = "t2.micro"
}
