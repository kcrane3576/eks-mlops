resource "aws_accessanalyzer_analyzer" "repo_scoped" {
  analyzer_name = var.repo_name
  type          = "ACCOUNT"

  tags = merge(var.tags, {
    Name = "${var.repo_name}-access-analyzer"
  })
}