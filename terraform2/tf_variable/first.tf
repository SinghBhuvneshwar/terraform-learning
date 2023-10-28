variable "age" {
  type =  number
}

variable "name" {
  type = string
}

output "userdata" {
  value = "name is ${var.name} and age is ${var.age}"
}