# Uses Terraform Registry version pinning (CKV_TF_1 skipped in .checkov.yml)
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
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
    Environment                                 = var.environment
  })

  public_subnet_tags = merge({
    "kubernetes.io/role/elb" = "1"
  }, { Environment = var.environment })

  private_subnet_tags = merge({ // Updated: Merge Environment tag for private subnets
    "kubernetes.io/role/internal-elb" = "1"
  }, { Environment = var.environment })
}

# Restricts default SG traffic post-VPC creation (CKV2_AWS_12 skipped in .checkov.yml)
resource "aws_default_security_group" "restrict_all" {
  vpc_id = module.vpc.vpc_id

  revoke_rules_on_delete = true

  ingress = []
  egress  = []

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# Custom NACL with Well-Architected best-practice rules (restrictive: deny inbound, allow outbound)
resource "aws_network_acl" "custom" {
  vpc_id = module.vpc.vpc_id # Reference module output

  # Inbound rules: Deny all (coarse restriction; add allows for specific ports if needed)
  ingress {
    protocol   = -1 # All protocols
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

  tags = merge(var.tags, {
    Name        = "${var.vpc_name}-custom-nacl",
    Environment = var.environment
  })
}

# Associate custom NACL with all private subnets (overrides default)
# Each subnet is associated with custom NACL using count() (CKV2_AWS_1 skipped in .checkov.yml)
# Flow logs and NAT EIPs are configured via input variables (CKV2_AWS_11, CKV2_AWS_19 skipped in .checkov.yml)
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