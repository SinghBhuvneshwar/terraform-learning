variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

provider "aws" {
  region     = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  # ami name=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  #root-device-type
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  #virtualization-type
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "ami_id" {
  value = data.aws_ami.ubuntu.id
}