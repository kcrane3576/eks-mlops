data "aws_iam_policy_document" "ops_admin_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [module.bastion.role_arn]
    }
  }
}

resource "aws_iam_role" "ops_admin" {
  name               = "${var.environment}-ops-admin"
  assume_role_policy = data.aws_iam_policy_document.ops_admin_trust.json
  tags = merge(
    local.default_tags, {
      Name = "${var.environment}-ops-admin"
    }
  )
}

data "aws_iam_policy_document" "ops_admin_read" {
  statement {
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListAddons",
      "eks:DescribeAddon"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ops_admin_read" {
  name   = "${var.environment}-ops-admin-read"
  policy = data.aws_iam_policy_document.ops_admin_read.json
}

resource "aws_iam_role_policy_attachment" "ops_admin_read_attach" {
  role       = aws_iam_role.ops_admin.name
  policy_arn = aws_iam_policy.ops_admin_read.arn
}

resource "aws_eks_access_entry" "ops_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.ops_admin.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "ops_admin_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.ops_admin.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope { type = "cluster" }
  depends_on = [aws_eks_access_entry.ops_admin]
}