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

  tags = {
    Environment = var.environment
    Repo        = var.repo_name
  }
}

module "access_analyzer" {
  source = "../../modules/iam/access_analyzer"

  repo_name   = var.repo_name
  environment = var.environment

  tags = {
    Environment = var.environment
    Repo        = var.repo_name
  }
}