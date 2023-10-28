variable "region" {}

variable "access_key" {}

variable "secret_key" {}

variable "port" {
  type = list(number)
}

variable "image_name" {
  type = string
}