module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  subnet_ids      = var.private_subnet_ids
  vpc_id          = var.vpc_id

  enable_irsa = true

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