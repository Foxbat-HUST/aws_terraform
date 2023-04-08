terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

module "vpc" {
    source = "../../modules/vpc"
    cidr_block = var.cidr_block
    tags = var.tags
    region = var.region
    public_subnet_data = var.public_subnet_data
    private_subnet_data = var.private_subnet_data
}