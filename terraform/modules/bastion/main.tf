data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "eks_describe" {
  name = "${var.name}-eks-describe"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["eks:DescribeCluster"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_describe_attach" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.eks_describe.arn
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.name}-bastion-profile"
  role = aws_iam_role.bastion.name

  tags = merge(var.tags, {
    Name = "${var.name}-bastion-profile"
  })
}

resource "aws_security_group" "bastion" {
  name   = "${var.name}-bastion-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-bastion-sg"
  })
}

data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail

    # Keep OS current
    dnf -y update

    # Ensure SSM Agent is installed and running on AL2023
    dnf -y install amazon-ssm-agent || true
    systemctl enable --now amazon-ssm-agent

    # kubectl + helm
    curl -sSL -o /usr/local/bin/kubectl https://amazon-eks.s3.${var.region}.amazonaws.com/1.29.0/2024-04-11/bin/linux/amd64/kubectl
    chmod +x /usr/local/bin/kubectl
    curl -sSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  EOT
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.small"
  subnet_id                   = var.private_subnet_ids[0]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  user_data                   = local.user_data

  metadata_options {
    http_tokens = "required"
  }

  depends_on = [
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.ssmmessages,
    aws_vpc_endpoint.ec2messages
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-bastion"
  })
}

resource "aws_security_group" "endpoints" {
  name   = "${var.name}-vpc-endpoints-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-vpc-endpoints-sg"
  })
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints.id]

  tags = merge(var.tags, {
    Name = "${var.name}-ssm-endpoint"
  })
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints.id]

  tags = merge(var.tags, {
    Name = "${var.name}-ssmmessages-endpoint"
  })
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints.id]

  tags = merge(var.tags, {
    Name = "${var.name}-ec2messages-endpoint"
  })
}

resource "aws_eks_access_entry" "bastion" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.bastion.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "bastion_admin" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.bastion.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope { type = "cluster" }
  depends_on = [aws_eks_access_entry.bastion]
}
