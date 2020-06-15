variable "tags" {
  description = "a map of resource tags for the module"
  type = map
}

variable "name" {
  description = "a name for the container repository"
  type = string
}

variable "max_image_count" {
  description = "the maximum number of container images in the repository"
  type = string
  default = 2
}