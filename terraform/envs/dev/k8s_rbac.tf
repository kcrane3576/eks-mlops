# PR role: view-only
resource "aws_eks_access_entry" "ci_read" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.ci_read_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "ci_read_view" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.ci_read_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  access_scope { type = "cluster" }
  depends_on = [aws_eks_access_entry.ci_read]
}

# Main role: cluster-admin (for bootstrapping controllers)
resource "aws_eks_access_entry" "ci_write" {
  count         = var.ci_write_role_arn != "" ? 1 : 0
  cluster_name  = module.eks.cluster_name
  principal_arn = var.ci_write_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "ci_write_admin" {
  count         = var.ci_write_role_arn != "" ? 1 : 0
  cluster_name  = module.eks.cluster_name
  principal_arn = var.ci_write_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope { type = "cluster" }
  depends_on = [aws_eks_access_entry.ci_write]
}
