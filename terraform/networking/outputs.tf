output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_dependency_trigger" {
  value = null_resource.vpc_dependency.id
  description = "Ensures full VPC creation before evaluating dependent resources"
}