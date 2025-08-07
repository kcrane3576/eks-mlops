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
  authentication_mode                      = "API"

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

resource "aws_eks_access_policy_association" "ci_write_access" {
  count = var.eks_cluster_access_policy != "" ? 1 : 0

  cluster_name  = var.cluster_name
  policy_arn    = var.eks_cluster_access_policy
  principal_arn = var.write_role_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [module.eks]
}