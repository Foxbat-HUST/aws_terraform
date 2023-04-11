terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

locals {
  all_ips = "0.0.0.0/0"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.tags
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.subnets_data)
  cidr_block        = element(var.subnets_data, count.index).public_cidr
  availability_zone = element(var.subnets_data, count.index).az
  vpc_id            = aws_vpc.vpc.id
  tags = {
    name = "public subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.subnets_data)
  cidr_block        = element(var.subnets_data, count.index).private_cidr
  availability_zone = element(var.subnets_data, count.index).az
  vpc_id            = aws_vpc.vpc.id
  tags = {
    name = "private subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = element(aws_subnet.public_subnets, 0).id
  depends_on    = [aws_internet_gateway.internet_gw]
}

resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = local.all_ips
    gateway_id = aws_internet_gateway.internet_gw.id
  }
}

resource "aws_route_table_association" "public_subnets_route_table_association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets, count.index).id
  route_table_id = aws_route_table.public_subnets_route_table.id
}


# resource "aws_default_route_table" "vpc_default_route_table" {
#   default_route_table_id = aws_vpc.vpc.default_route_table_id
# }

resource "aws_route_table" "private_subnet_route_table_with_nat_gw" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = local.all_ips
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    name = "route table for private subnet with nat gw"
  }
}

resource "aws_route_table_association" "private_subnets_route_table_association" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = element(aws_subnet.private_subnets, count.index).id
  route_table_id = aws_route_table.private_subnet_route_table_with_nat_gw.id
}
