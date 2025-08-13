variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs"
  sensitive   = true
}

variable "kubernetes_minor_version" {
  type        = string
  description = "Kubernetes minor version"
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