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

  private_subnet_tags = merge(var.tags, {
    Name                                        = "${var.vpc_name}-private-subnets",
    "kubernetes.io/role/internal-elb"           = "1",
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = module.vpc.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = module.vpc.private_route_table_ids


  tags = merge(var.tags, {
    Name = "${var.vpc_name}-s3-endpoint"
  })
}
