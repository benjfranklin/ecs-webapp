variable "name" {
  description = ""
  type = string
}

variable "vpc_id" {
  description = ""
  type = string
}

variable "vpc_subnets" {
  description = ""
  type = list
}

variable "backend_sg_id" {
  description = ""
  type = string
}

variable "log_bucket_name" {
  description = ""
  type = string
}

variable "tags" {
  description = ""
  type = map
}
