provider "aws" {
  region = "us-east-1"
}

variable "ami" {
  description = "This is Ubuntu Ami"
}

variable "aws_instance" {
  description = "Instance Type"
}

resource "aws_instance" "ubuntinstance" {
  ami = var.ami
  instance_type = var.aws_instance
}