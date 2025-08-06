module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  manage_default_network_acl = false

  enable_flow_log                           = true
  create_flow_log_cloudwatch_log_group      = true
  create_flow_log_cloudwatch_iam_role       = true
  flow_log_cloudwatch_log_group_name_prefix = "/aws/vpc-flow-log/"

  tags = merge(var.tags, {
    Name                                        = var.vpc_name,
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })

  public_subnet_tags = merge(var.tags, {
    Name                     = "${var.vpc_name}-public-subnets",
    "kubernetes.io/role/elb" = "1"
  })

  private_subnet_tags = merge(var.tags, { // Updated: Merge Environment tag for private subnets
    Name                                        = "${var.vpc_name}-private-subnets",
    "kubernetes.io/role/internal-elb"           = "1",
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}

resource "aws_default_security_group" "default_vpc" {
  vpc_id = module.vpc.vpc_id
  revoke_rules_on_delete = true

  ingress {
    description      = "Allow HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  ingress {
    description      = "Allow DNS"
    from_port        = 53
    to_port          = 53
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  egress {
    description      = "Allow all egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-default-eks-security-group"
  })
}

# Custom NACL with Well-Architected best-practice rules (restrictive: deny inbound, allow outbound)
resource "aws_network_acl" "custom" {
  vpc_id = module.vpc.vpc_id

  # Inbound: Allow HTTPS (443) for EKS control plane communication
  ingress {
    protocol   = "tcp"
    rule_no    = 90
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Inbound: Allow kubelet (10250) for node-to-control-plane communication
  ingress {
    protocol   = "tcp"
    rule_no    = 91
    action     = "allow"
    cidr_block = module.vpc.vpc_cidr_block
    from_port  = 10250
    to_port    = 10250
  }

  # Inbound: Allow DNS (53, TCP/UDP)
  ingress {
    protocol   = "tcp"
    rule_no    = 92
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }
  ingress {
    protocol   = "udp"
    rule_no    = 93
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }

  # Inbound: Allow ephemeral ports for return traffic
  ingress {
    protocol   = "tcp"
    rule_no    = 94
    action     = "allow"
    cidr_block = module.vpc.vpc_cidr_block
    from_port  = 1024
    to_port    = 65535
  }

  # Inbound: Allow AWS VPC CNI webhook (61678)
  ingress {
    protocol   = "tcp"
    rule_no    = 95
    action     = "allow"
    cidr_block = module.vpc.vpc_cidr_block
    from_port  = 61678
    to_port    = 61678
  }

  # Inbound: Allow VXLAN for CNI (if using Calico or similar)
  ingress {
    protocol   = "udp"
    rule_no    = 96
    action     = "allow"
    cidr_block = module.vpc.vpc_cidr_block
    from_port  = 4789
    to_port    = 4789
  }

  # Inbound: Deny all other traffic
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "-1"
    rule_no    = 101
    action     = "deny"
    ipv6_cidr_block = "::/0"
    from_port  = 0
    to_port    = 0
  }

  # Outbound: Allow all
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = "-1"
    rule_no    = 101
    action     = "allow"
    ipv6_cidr_block = "::/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-custom-nacl"
  })
}

# Associate custom NACL with all private subnets (overrides default)
resource "aws_network_acl_association" "private" {
  count = length(module.vpc.private_subnets)

  network_acl_id = aws_network_acl.custom.id
  subnet_id      = module.vpc.private_subnets[count.index]
}

# Associate custom NACL with all public subnets (overrides default)
resource "aws_network_acl_association" "public" {
  count = length(module.vpc.public_subnets)

  network_acl_id = aws_network_acl.custom.id
  subnet_id      = module.vpc.public_subnets[count.index]
}