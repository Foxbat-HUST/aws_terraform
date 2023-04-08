terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

module "vpc" {
  source              = "../../modules/vpc"
  cidr_block          = var.cidr_block
  tags                = var.tags
  region              = var.region
  public_subnet_data  = var.public_subnet_data
  private_subnet_data = var.private_subnet_data
}

module "app" {
  source        = "../../modules/app"
  region        = var.region
  instance_spec = var.instance_spec
  ssh_key       = var.ssh_key
  vpc_id        = module.vpc.vpc_id
  public_subnet_data = {
    cidr = module.vpc.public_subnet_cidr
    id   = module.vpc.public_subnet_id
  }
  private_subnets_data = [for i in range(length(module.vpc.private_subnets_cidr)) : {
    id   = module.vpc.private_subnets_id[i]
    cidr = module.vpc.private_subnets_cidr[i]
  }]
  tags = var.tags
}

