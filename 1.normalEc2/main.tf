
provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "logicalname" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ data.aws_security_groups.all.ids[0] ]
  key_name = "test"
  
} 