variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs"
  sensitive   = true
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name for tags"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}

variable "eks_cluster_access_policy" {
  description = "IAM policy ARN to associate with the CI principal for Kubernetes access"
  type        = string
}

variable "write_role_arn" {
  description = "IAM role ARN for CI that should get EKS Kubernetes access"
  type        = string
}