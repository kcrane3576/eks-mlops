resource "kubernetes_namespace" "bootstrap_test" {
  count = var.enable_k8s_bootstrap ? 1 : 0
  metadata { name = "bootstrap-test" }
}