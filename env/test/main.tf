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
  source             = "../../modules/app"
  region             = var.region
  instance_spec      = var.instance_spec
  ssh_key            = var.ssh_key
  vpc_id             = module.vpc.vpc_id
  public_subnet_id   = module.vpc.public_subnet_id
  private_subnet_ids = module.vpc.private_subnet_ids
  tags               = var.tags
}

