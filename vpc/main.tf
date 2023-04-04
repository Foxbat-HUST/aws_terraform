variable "region" {
  type        = string
  description = "vpc region"
  default     = "ap-northeast-1"
}
variable "tags" {
  type        = map(string)
  description = "tags list"
  default = {
    author = "anpq"
    tool   = "terraform"
  }
}
variable "cidr_block" {
  type        = string
  description = "vpc cidr block"
  default     = "192.168.0.0/16"
}

variable "ec2_data" {
  type        = map(string)
  description = "ec2 ami and type"
  default = {
    ami           = "ami-0d979355d03fa2522"
    instance_type = "t2.micro"
  }
}

variable "public_subnet_data" {
  type        = list(map(string))
  description = "public subnet cidr blocks and az"
  default = [
    {
      cidr = "192.168.1.0/24"
      az   = "ap-northeast-1a"
    },
    {
      cidr = "192.168.2.0/24"
      az   = "ap-northeast-1c"
    }
  ]
}

variable "private_subnet_data" {
  type        = list(map(string))
  description = "private subnet cidr blocks and az"
  default = [
    {
      cidr = "192.168.3.0/24"
      az   = "ap-northeast-1a"
    },
    {
      cidr = "192.168.4.0/24"
      az   = "ap-northeast-1c"
    }
  ]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags       = merge(var.tags, { name = "main vpc" })
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_data)
  cidr_block        = element(var.public_subnet_data, count.index).cidr
  availability_zone = element(var.public_subnet_data, count.index).az
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(var.tags, { name = "public subnet ${count.index + 1}" })
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_data)
  cidr_block        = element(var.private_subnet_data, count.index).cidr
  availability_zone = element(var.private_subnet_data, count.index).az
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(var.tags, { name = "private subnet ${count.index + 1}" })
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { name = "internet gw" })
}

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets, count.index).id
  route_table_id = aws_route_table.public_subnet_route_table.id
}


resource "aws_default_security_group" "defautl_sg" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    description = "enable http"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    description = "enable http"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "enable ssh"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "enable ping"
    protocol = "icmp"
    from_port = 8
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2" {
  ami                         = var.ec2_data.ami
  instance_type               = var.ec2_data.instance_type
  availability_zone           = element(var.public_subnet_data, 0).az
  subnet_id                   = element(aws_subnet.public_subnets, 0).id
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash
apt update -y
apt install -y apache2
systemctl start apache2
systemctl enable apache2
mkdir -p /var/www/html/
echo "<h1>hello message from host 02</h1>" > /var/www/html/index.html
EOF
}


