terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes",
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm",
      version = "~> 2.13"
    }
  }
}

module "networking" {
  source = "../../modules/networking"
  providers = {
    aws = aws.ci_write_role
  }

  vpc_name             = var.vpc_name
  region               = var.region
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
  providers = {
    aws = aws.ci_write_role
  }

  access_analyzer_name = "${var.repo_name}-access-analyzer"

  tags = local.default_tags
}


module "eks" {
  source = "../../modules/eks"
  providers = {
    aws = aws.ci_write_role
  }

  kubernetes_minor_version = var.kubernetes_minor_version
  cluster_name             = var.cluster_name
  vpc_id                   = module.networking.vpc_id
  private_subnet_ids       = module.networking.private_subnets

  tags = local.default_tags
}

module "bastion" {
  source = "../../modules/bastion"
  providers = {
    aws = aws.ci_write_role
  }

  name                              = var.bastion_name
  region                            = var.region
  environment                       = var.environment
  vpc_id                            = module.networking.vpc_id
  private_subnet_ids                = module.networking.private_subnets
  kubernetes_minor_version          = var.kubernetes_minor_version
  cluster_name                      = module.eks.cluster_name
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  s3_gateway_endpoint_id            = module.networking.s3_gateway_endpoint_id

  depends_on = [module.eks]

  tags = local.default_tags
}


locals {
  default_tags = {
    Environment = var.environment
    Repo        = var.repo_name
  }
  policy_tags = merge(
    local.default_tags,
    {
      owner   = "platform",
      purpose = "ci"
    }
  )
}