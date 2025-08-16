data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Used to dynamically resolve the AWS account ID so we can build role ARNs
# without hardcoding account numbers (keeps policies portable across environments)
data "aws_caller_identity" "current_account" {}

resource "aws_iam_policy" "bastion_eks_describe_cluster" {
  name        = "${var.name}-eks-describe-cluster"
  description = "Allow bastion to DescribeCluster for kubeconfig generation"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["eks:DescribeCluster"],
      Resource = "arn:aws:eks:${var.region}:${data.aws_caller_identity.current_account.account_id}:cluster/${var.cluster_name}"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_eks_describe_cluster_attach" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.bastion_eks_describe_cluster.arn
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
  user_data = templatefile("${path.module}/scripts/bootstrap.sh", {
    region        = var.region
    cluster_name  = var.cluster_name
    environment   = var.environment
    account_id    = data.aws_caller_identity.current_account.account_id
    eks_minor     = var.kubernetes_minor_version
    eks_artifacts = "us-west-2"
  })
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