output "policy_arn" {
  value = aws_iam_policy.gh_ci_vpc_state_read.policy.arn
}

output "policy_name" {
  value = aws_iam_policy.gh_ci_vpc_state_read.policy.name
}