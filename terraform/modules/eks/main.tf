module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_minor_version
  subnet_ids         = var.private_subnet_ids
  vpc_id             = var.vpc_id

  enable_irsa         = true
  authentication_mode = "API"

  endpoint_private_access = true
  endpoint_public_access  = false

  enabled_log_types                      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = 365
  enable_kms_key_rotation                = true

  create_security_group = true

  eks_managed_node_groups = {
    default = {
      create_security_group = true
      ami_type              = "AL2023_x86_64_STANDARD"
      force_update_version  = true
      instance_types        = ["t3.medium"]
      min_size              = 1
      max_size              = 3
      desired_size          = 2

      # Optionally add labels, taints, or extra configs
      labels = {
        role = "worker"
      }

      tags = {
        Name = "${var.cluster_name}-node-group"
      }
    }
  }

  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}