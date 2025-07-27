resource "aws_accessanalyzer_analyzer" "repo_scoped" {
  analyzer_name = var.repo_name
  type          = "ACCOUNT"

  tags = var.tags
}