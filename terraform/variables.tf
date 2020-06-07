variable "tags" {
    type = map
}

variable "region" {
    type = string
}

variable "vpc_name" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "vpc_azs" {
    type = list
}

variable "vpc_private_subnets" {
    type = list
}

variable "vpc_public_subnets" {
    type = list
}

variable "ecs_cluster_name" {
    type = string
}

variable "alb_name" {
    type = string
}

variable "alb_ssl_cert_filename" {
    type = string
    default = "cert.pem"
}

variable "alb_ssl_key_filename" {
    type = string
    default = "key.pem"
}



