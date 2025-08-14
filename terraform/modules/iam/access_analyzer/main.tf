resource "aws_accessanalyzer_analyzer" "repo_scoped" {
  analyzer_name = var.access_analyzer_name
  type          = "ACCOUNT"

  tags = merge(var.tags, {
    Name = "${var.access_analyzer_name}"
  })
}