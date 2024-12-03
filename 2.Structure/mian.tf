provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "test" {
  name   = "test1"  # this name will display
  vpc_id = data.aws_vpc.selected.id
}

resource "aws_vpc_security_group_ingress_rule" "inbound" {
  security_group_id = aws_security_group.test.id # here reference name is taken not main name test1
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_instance" "Test" {
  ami                    = var.ami_name
  instance_type          = var.type_ins
  vpc_security_group_ids = [aws_security_group.test.id]
}