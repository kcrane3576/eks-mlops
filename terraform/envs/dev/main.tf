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

resource "time_sleep" "after_ci_policy_attach" {
  create_duration = "20s"
  depends_on      = [aws_iam_role_policy_attachment.attach_ci_read_vpc_state]
}

module "networking" {
  source = "../../modules/networking"

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

  depends_on = [
    module.gh_ci_read_vpc_state,
    aws_iam_role_policy_attachment.attach_ci_read_vpc_state,
    time_sleep.after_ci_policy_attach
  ]
}

module "access_analyzer" {
  source = "../../modules/iam/access_analyzer"

  access_analyzer_name = "${var.repo_name}-access-analyzer"

  tags = local.default_tags

  depends_on = [module.networking]
}


module "eks" {
  source = "../../modules/eks"

  kubernetes_minor_version = var.kubernetes_minor_version
  cluster_name             = var.cluster_name
  vpc_id                   = module.networking.vpc_id
  private_subnet_ids       = module.networking.private_subnets

  tags = local.default_tags
}

module "bastion" {
  source = "../../modules/bastion"

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