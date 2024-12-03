provider "aws" {
  region = "us-east-1"
}

module "ec2withvar" {
    source = "./module_without_var/ec2withoutvar"
    ami_name = "ami-0182f373e66f89c85"
    type_ins = "t2.micro"
}