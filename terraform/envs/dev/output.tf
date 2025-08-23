output "vpc_id" {
  value = module.networking.vpc_id
}

output "private_subnets" {
  value = module.networking.private_subnets
}

output "public_subnets" {
  value = module.networking.public_subnets
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_node_group_role_arn" {
  value = module.eks.node_group_role_arn
}

output "cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "cluster_certificate_authority_data" {
  sensitive = true
  value     = module.eks.cluster_certificate_authority_data
}

output "instance_id" {
  sensitive = true
  value     = module.bastion.instance_id
}

output "ops_admin_role_arn" {
  value = aws_iam_role.ops_admin.arn
}