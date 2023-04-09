terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

module "vpc" {
  source       = "../../modules/vpc"
  cidr_block   = var.cidr_block
  tags         = var.tags
  region       = var.region
  subnets_data = var.subnets_data
}

module "app" {
  source               = "../../modules/app"
  region               = var.region
  instance_spec        = var.instance_spec
  ssh_key              = var.ssh_key
  vpc_id               = module.vpc.vpc_id
  public_subnets_data  = module.vpc.public_subnets_data
  private_subnets_data = module.vpc.private_subnets_data
  tags                 = var.tags
}

