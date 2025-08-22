variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, test, prod) for tagging and IAM scoping"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "state_bucket_name" {
  type        = string
  description = "Terraform state bucket name"

}
variable "state_lock_table_name" {
  type        = string
  description = "Terraform state dynamoDB table name"
}

variable "policy_name" {
  type        = string
  description = "Policy name"

}

variable "policy_description" {
  type        = string
  description = "Policy description"
}

variable "policy_path" {
  type        = string
  description = "Policy path"
}

variable "policy_tags" {
  type        = map(string)
  description = "Policy tags"
}
