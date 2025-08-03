terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.64.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "networking" {
  source = "../../modules/networking"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_vpc_flow_logs = var.enable_vpc_flow_logs
  cluster_name         = var.cluster_name
  environment          = var.environment
  repo_name            = var.repo_name

  tags = local.default_tags
}

module "access_analyzer" {
  source = "../../modules/iam/access_analyzer"

  repo_name   = var.repo_name
  environment = var.environment

  tags = local.default_tags
}


module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnets

  tags = local.default_tags
}

locals {
  default_tags = {
    Environment = var.environment
    Repo        = var.repo_name
  }
}