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
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags       = var.tags
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
  count = length(aws_subnet.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags   = var.tags
}

resource "aws_default_route_table" "vpc_default_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_route_table" "public_subnet_route_table" {
  count = length(aws_subnet.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = local.all_ips
    gateway_id = aws_internet_gateway.internet_gw[0].id
  }
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  count = length(aws_subnet.public_subnets)
  subnet_id = element(aws_subnet.public_subnet_data,count.index).id
  route_table_id = aws_route_table.public_subnet_route_table.id
}
