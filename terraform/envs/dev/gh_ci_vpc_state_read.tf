locals {
  ci_read_role_name  = element(reverse(split("/", var.ci_read_role_arn)), 0)
  ci_write_role_name = element(reverse(split("/", var.ci_write_role_arn)), 0)
  ci_roles_to_attach = toset(
    compact([
      local.ci_read_role_name,
      local.ci_write_role_name
    ])
  )

  policy_name        = "gh_ci_vpc_state_read"
  policy_description = "Read-only access for CI to Terraform state (S3/DynamoDB) + VPC flow log IAM reads"
  policy_path        = "/platform/ci/vpc/"
  policy_tags = merge(
    local.default_tags,
    {
      owner   = "platform",
      purpose = "ci"
    }
  )
}

module "gh_ci_read_vpc_state" {
  source = "../../modules/iam/github_oidc_roles/read_policies/vpc_state"

  region                = var.region
  environment           = var.environment
  state_bucket_name     = var.state_bucket_name
  state_lock_table_name = var.state_lock_table_name

  policy_name        = local.policy_name
  policy_description = local.policy_description
  policy_path        = local.policy_path
  policy_tags        = local.policy_tags
}

resource "aws_iam_role_policy_attachment" "attach_ci_read_vpc_state" {
  for_each   = local.ci_roles_to_attach
  role       = each.value
  policy_arn = module.gh_ci_read_vpc_state.policy_arn
}