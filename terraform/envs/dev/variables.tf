variable "region" {
  type        = string
  description = "AWS region"
}

variable "ci_write_role_arn" {
  type        = string
  description = "CI Write role ARN"
}

variable "ci_read_role_arn" {
  type        = string
  description = "CI Read role ARN"
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

variable "kubernetes_minor_version" {
  type        = string
  description = "Kubernetes minor version"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name for tags"
}

variable "enable_k8s_bootstrap" {
  type        = bool
  default     = false
  description = "Enable Kubernetes/Helm resources from Terraform."
}

variable "bastion_name" {
  type        = string
  description = "Bastion name for tags"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, test, prod) for tagging and IAM scoping"
}

variable "repo_name" {
  type        = string
  description = "Github repository name"
}