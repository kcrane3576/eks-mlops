locals {
  provider_external_id = "ci-orchestrator-dev"
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "ci_write_role"
  region = var.region
  assume_role {
    role_arn     = var.ci_write_role_arn
    session_name = "tf_ci_write_role"
    external_id  = local.provider_external_id
  }
}