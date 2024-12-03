provider "aws" {
  region = "us-east-1"
}
variable "ami" {
  
}
variable "aws_instance" {
  description = "How to do auto assign workspace"
  type = map(string)
  default = {
    "dev" = "t2.micro"
    "stage" = "t2.micro"
    "prod" = "t2.micro"
  }

}
module "CreateEc2" {
    source = "./module/ec2Instance"
    ami = var.ami
    aws_instance = lookup(var.aws_instance,terraform.workspace,"t2.micro")
}