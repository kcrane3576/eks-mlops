variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_name" {
  type        = string
  description = "VPC name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  sensitive   = true
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnet CIDRs"
  sensitive   = true
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnet CIDRs"
  sensitive   = true
}

variable "enable_vpc_flow_logs" {
  type        = bool
  description = "Enable VPC flow logs for security auditing"
  default     = true
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name for tags"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, test, prod) for tagging and IAM scoping"
}

variable "repo_name" {
  type        = string
  description = "Github repository name"
}

variable "eks_cluster_access_policy" {
  description = "IAM policy ARN to associate with the CI principal for Kubernetes access"
  type        = string
}

variable "write_role_arn" {
  description = "IAM role ARN for CI that should get EKS Kubernetes access"
  type        = string
}