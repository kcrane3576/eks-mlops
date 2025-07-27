variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, test, prod) for tagging and IAM scoping"
}

variable "repo_name" {
  type        = string
  description = "Github repository name"
}