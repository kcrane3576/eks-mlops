# Used to dynamically resolve the AWS account ID so we can build role ARNs
# without hardcoding account numbers (keeps policies portable across environments)
data "aws_caller_identity" "current_account" {}

locals {
  account_id          = data.aws_caller_identity.current_account.account_id
  s3_bucket_arn       = "arn:aws:s3:::${var.state_bucket_name}"
  s3_objs_arn         = "${local.s3_bucket_arn}/*"
  dynamodb_table_arn  = "arn:aws:dynamodb:${var.region}:${local.account_id}:table/${var.state_lock_table_name}"
  flow_log_role_arn   = "arn:aws:iam::${local.account_id}:role/vpc-flow-log-role-*"
  flow_log_policy_arn = "arn:aws:iam::${local.account_id}:policy/vpc-flow-log-to-cloudwatch-*"
}

data "aws_iam_policy_document" "s3_read_state" {
  statement {
    sid    = "S3ReadTerraformState"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [
      local.s3_bucket_arn,
      local.s3_objs_arn
    ]
  }
}

data "aws_iam_policy_document" "dynamodb_lock_read" {
  statement {
    sid    = "DynamoDBReadTerraformStateLock"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:DescribeTable"
    ]
    resources = [
      local.dynamodb_table_arn
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [var.environment]
    }
  }
}

data "aws_iam_policy_document" "flow_log_role_read" {
  statement {
    sid    = "IAMReadVPCFlowLogRoles"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole"
    ]
    resources = [local.flow_log_role_arn]
  }
}

data "aws_iam_policy_document" "flow_log_policy_read" {
  statement {
    sid    = "IAMReadVPCFlowLogPolicies"
    effect = "Allow"
    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions"
    ]
    resources = [local.flow_log_policy_arn]
  }
}

data "aws_iam_policy_document" "gh_ci_vpc_state_read_doc" {
  source_policy_documents = [
    data.aws_iam_policy_document.s3_read_state.json,
    data.aws_iam_policy_document.dynamodb_lock_read.json,
    data.aws_iam_policy_document.flow_log_role_read.json,
    data.aws_iam_policy_document.flow_log_policy_read.json
  ]
}

resource "aws_iam_policy" "gh_ci_vpc_state_read" {
  name        = var.policy_name
  description = var.policy_description
  path        = var.policy_path
  policy      = data.aws_iam_policy_document.gh_ci_vpc_state_read_doc.json
  tags        = var.policy_tags
}