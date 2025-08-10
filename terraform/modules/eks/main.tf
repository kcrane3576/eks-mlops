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
  endpoint_public_access                   = true

  create_security_group = true

  # Add inbound rules to the cluster SG for nodes to communicate
  security_group_additional_rules = {
    allow_all_egress = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  }

  eks_managed_node_groups = {
    default = {
      create_security_group = true
      ami_type              = "AL2_x86_64"
      force_update_version  = true
      instance_types        = ["t3.medium"]
      min_size              = 1
      max_size              = 3
      desired_size          = 2

      # Optionally add labels, taints, or extra configs
      labels = {
        role = "worker"
      }

      iam_role_additional_policies = {
        ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
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