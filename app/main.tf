resource "kubernetes_namespace" "gitops_demo_namespace" {
  metadata {
    name = "gitops-demo-app"
  }
}