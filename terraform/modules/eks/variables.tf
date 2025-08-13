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

variable "bastion_sg_id" {
  type        = string
  description = "Bastion Security Group ID"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}