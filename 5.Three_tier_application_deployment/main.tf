provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc-demo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_subnet" "public-subnet-demo" {
    vpc_id = aws_vpc.vpc-demo.id
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "public-subnet-demo"
    }
}

resource "aws_subnet" "private-subnet-demo" {
    vpc_id = aws_vpc.vpc-demo.id
    cidr_block = "10.0.2.0/24"
    tags = {
        Name = "private-subnet-demo"
    }
}

resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.vpc-demo.id
  tags = {
    Name = "demo-igw"
  }
}

resource "aws_route_table" "for-public-subnet" {
  vpc_id = aws_vpc.vpc-demo.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }
  tags = {
    Name = "for-public-subnet"
  }
}

resource "aws_route_table_association" "for-public-subnet" {
  subnet_id = aws_subnet.public-subnet-demo.id
  route_table_id = aws_route_table.for-public-subnet.id
}

resource "aws_instance" "pubilc-server" {
  ami = "ami-0e86e20dae9224db8"
  key_name = "test"
  subnet_id = aws_subnet.public-subnet-demo.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  source_dest_check = false
  tags = {
    Name = "pubilc-server"
  }

  user_data = <<-EOF
                #!/bin/bash
                apt-get update
                apt-get install -y iptables-persistent
                sysctl -w net.ipv4.ip_forward=1
                echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

                # Automatically determine the correct interface for the public and private network
                PUBLIC_IFACE=$(ip route | grep default | awk '{print $5}')
                PRIVATE_IFACE=$(ip -o link show | grep 'state UP' | awk '{print $2}' | sed 's/:$//')

                iptables -t nat -A POSTROUTING -o $PUBLIC_IFACE -j MASQUERADE
                iptables -A FORWARD -i $PRIVATE_IFACE -o $PUBLIC_IFACE -j ACCEPT
                iptables -A FORWARD -i $PUBLIC_IFACE -o $PRIVATE_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
                iptables-save > /etc/iptables/rules.v4
              EOF
}

resource "aws_instance" "private-server" {
  ami = "ami-0e86e20dae9224db8"
  key_name = "test"
  subnet_id = aws_subnet.private-subnet-demo.id
  instance_type = "t2.micro"
  tags = {
    Name = "private-server"
  }
}

resource "aws_route_table" "for-private-subnet" {
  vpc_id = aws_vpc.vpc-demo.id
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.pubilc-server.primary_network_interface_id
  }
  tags = {
    Name = "for-private-subnet"
  }
}

resource "aws_route_table_association" "for-private-subnet" {
  subnet_id = aws_subnet.private-subnet-demo.id
  route_table_id = aws_route_table.for-private-subnet.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc-demo.id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
    description = "The public ip is "
    value = aws_instance.pubilc-server.public_ip

}
output "private_ip" {
    description = "The private ip is "
    value = aws_instance.private-server.private_ip
}
