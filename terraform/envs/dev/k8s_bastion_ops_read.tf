# 1) Trust: let the bastion instance role assume the ops-read role
data "aws_iam_policy_document" "ops_read_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [module.bastion.role_arn]
    }
  }
}

resource "aws_iam_role" "ops_read" {
  name               = "${var.environment}-ops-read"
  assume_role_policy = data.aws_iam_policy_document.ops_read_trust.json
  tags = merge(
    local.default_tags, {
      Name = "${var.environment}-ops-read"
    }
  )
}

# 2) Minimal AWS reads used by Bastion
data "aws_iam_policy_document" "ops_read" {
  statement {
    sid    = "EKSReads"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListAddons",
      "eks:DescribeAddon",
      "eks:ListAccessEntries",
      "eks:DescribeAccessEntry",
      "eks:ListAssociatedAccessPolicies"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "LogsDescribe"
    effect    = "Allow"
    actions   = ["logs:DescribeLogGroups"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ops_read" {
  name   = "${var.environment}-ops-read-policy"
  policy = data.aws_iam_policy_document.ops_read.json
}

resource "aws_iam_role_policy_attachment" "ops_read_attach" {
  role       = aws_iam_role.ops_read.name
  policy_arn = aws_iam_policy.ops_read.arn
}

# 3) Map THE OPS-READ ROLE (not the bastion) to the cluster with view RBAC
resource "aws_eks_access_entry" "ops_read" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.ops_read.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "ops_read_view" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.ops_read.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  access_scope { type = "cluster" }
  depends_on = [aws_eks_access_entry.ops_read]
}
