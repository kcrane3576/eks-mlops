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

  tags = merge(var.tags, {
    Name = "${var.name}-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Allow pulling kubectl from amazon-eks S3 bucket (us-west-2)
resource "aws_iam_policy" "bastion_s3_read_eks_artifacts" {
  name        = "${var.name}-s3-read-amazon-eks"
  description = "Read kubectl from amazon-eks bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { "Sid" : "ListBucket", "Effect" : "Allow", "Action" : ["s3:ListBucket"], "Resource" : "arn:aws:s3:::amazon-eks" },
      { "Sid" : "GetObjects", "Effect" : "Allow", "Action" : ["s3:GetObject"], "Resource" : "arn:aws:s3:::amazon-eks/*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_s3_read_attach" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.bastion_s3_read_eks_artifacts.arn
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.name}-profile"
  role = aws_iam_role.bastion.name
  tags = merge(var.tags, {
    Name = "${var.name}-profile"
  })
}

resource "aws_security_group" "bastion" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "bastion_to_eks_api" {
  security_group_id            = var.cluster_primary_security_group_id
  description                  = "Allow bastion to reach EKS API"
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.bastion.id
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

data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  eks_artifacts_region     = "us-west-2"
  kubernetes_minor_version = var.kubernetes_minor_version

  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail

    dnf -y update
    dnf -y install amazon-ssm-agent awscli jq || true
    systemctl enable --now amazon-ssm-agent

    mkdir -p /tmp/k8s

    echo "Finding latest kubectl for ${local.kubernetes_minor_version}..."
    LATEST_PATH=$(aws --region ${local.eks_artifacts_region} s3 ls s3://amazon-eks/ --recursive \
      | grep "bin/linux/amd64/kubectl$" \
      | grep "^.*${local.kubernetes_minor_version}\\." \
      | sort \
      | tail -n 1 \
      | awk '{print $4}')

    if [ -z "$LATEST_PATH" ]; then
      echo "ERROR: Could not find kubectl for ${local.kubernetes_minor_version} in S3 bucket amazon-eks"
      exit 1
    fi

    echo "Downloading kubectl from s3://amazon-eks/$LATEST_PATH"
    aws --region ${local.eks_artifacts_region} s3 cp "s3://amazon-eks/$LATEST_PATH" /tmp/k8s/kubectl
    install -m 0755 /tmp/k8s/kubectl /usr/local/bin/kubectl
    kubectl version --client || true

    # --- Helm & Kustomize ---
    dnf -y install tar gzip curl jq || true

    # Helm v3
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash || true
    helm version || true

    # Kustomize (latest)
    K_VER=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases \
      | jq -r '.[0].tag_name' | sed 's/kustomize\///')
    curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/$${K_VER}/kustomize_$${K_VER}_linux_amd64.tar.gz" \
      -o /tmp/kustomize.tgz || true
    tar -xzf /tmp/kustomize.tgz -C /usr/local/bin/ || true
    kustomize version || true

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
    Name                = "${var.name}",
    S3GatewayEndpointId = var.s3_gateway_endpoint_id
  })
}