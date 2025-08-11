variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs"
  sensitive   = true
}

variable "name" {
  type        = string
  description = "Bastion name"
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