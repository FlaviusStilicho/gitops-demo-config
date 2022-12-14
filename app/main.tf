resource "kubernetes_namespace" "gitops_demo_namespace" {
  metadata {
    name = "gitops-demo-app"
  }
}


resource "kubernetes_deployment" "demo_app" {
  metadata {
    name      = local.app_name
    namespace = kubernetes_namespace.gitops_demo_namespace.metadata.0.name
  }

  spec {
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = local.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.app_name
        }
      }
      spec {
        container {
          name  = local.app_name
          image = "alexbakker/gitops-demo:${trimspace(file("./app_version.txt"))}"
#          liveness_probe {
#            http_get {
#              path = "/health"
#              port = "http"
#            }
#            initialDelaySeconds : 15
#            periodSeconds : 5
#          }
          port {
            name           = "http"
            container_port = local.app_port
          }
        }
      }
    }
  }
}