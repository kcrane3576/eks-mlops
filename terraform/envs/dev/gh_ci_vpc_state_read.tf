locals {
  ci_read_role_name  = element(reverse(split("/", var.ci_read_role_arn)), 0)
  policy_name        = "gh_ci_vpc_state_read"
  policy_description = "Read-only access for CI to Terraform state (S3/DynamoDB) + VPC flow log IAM reads"
  policy_path        = "/platform/ci/vpc/"
  policy_tags = merge(
    local.default_tags,
    {
      owner   = "platform",
      purpose = "ci-plan"
    }
  )
}

module "gh_ci_read_vpc_state" {
  source = "../../modules/iam/github_oidc_roles/read_policies/vpc_state"

  region                = var.region
  environment           = var.environment
  state_bucket_name     = var.state_bucket_name
  state_lock_table_name = var.state_lock_table_name

  # env-controlled knobs
  policy_name        = local.policy_name
  policy_description = local.policy_description
  policy_path        = local.policy_path
  policy_tags        = local.policy_tags
}

# Attach to your existing CI Read role (by NAME)
resource "aws_iam_role_policy_attachment" "attach_ci_read_vpc_state" {
  role       = local.ci_read_role_name
  policy_arn = module.gh_ci_read_vpc_state.policy_arn
}