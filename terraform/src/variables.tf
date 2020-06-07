variable "account_id" {
  default = "776475658441"
}

variable "region" {
    default = "eu-west-2"
}

variable "image_name" {
  description = "Name to use for deployed Docker image"
  default = "webserver-image"
}

variable "image_tag" {
  description = "Tag to use for deployed Docker image"
  default     = "latest"
}

