locals {
  provider_external_id = "ci-orchestrator-dev"
}

provider "aws" {
  region = var.region
}