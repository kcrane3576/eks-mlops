provider "aws" {
  region = "us-east-1"
}

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

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_cloudwatch_log_group_name_prefix = "/aws/vpc-flow-log/"

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Custom NACL with Well-Architected best-practice rules (restrictive: deny inbound, allow outbound)
resource "aws_network_acl" "custom" {
  vpc_id = module.vpc.vpc_id  # Reference module output

  # Inbound rules: Deny all (coarse restriction; add allows for specific ports if needed)
  ingress {
    protocol   = -1  # All protocols
    rule_no    = 100
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol        = -1
    rule_no         = 101
    action          = "deny"
    ipv6_cidr_block = "::/0"
    from_port       = 0
    to_port         = 0
  }

  # Outbound rules: Allow all (for responses; stateless, so necessary for return traffic)
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol        = -1
    rule_no         = 101
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 0
    to_port         = 0
  }

  tags = merge(var.tags, { Name = "${var.vpc_name}-custom-nacl" })
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