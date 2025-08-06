module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0.0"

  name               = var.cluster_name
  kubernetes_version = "1.29"
  subnet_ids         = var.private_subnet_ids
  vpc_id             = var.vpc_id

  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true
  enabled_log_types                        = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  enable_kms_key_rotation                  = true
  cloudwatch_log_group_retention_in_days   = 365
  authentication_mode                   = "API_AND_CONFIG_MAP"

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2

      # Optionally add labels, taints, or extra configs
      labels = {
        role = "worker"
      }

      tags = {
        Name = "${var.cluster_name}-node-group"
      }
    }
  }

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}