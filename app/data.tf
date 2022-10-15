data "google_client_config" "provider" {}

data "google_container_cluster" "primary" {
  name = "nc-alex-bakker-gke"
  location = "europe-west4"
  project = local.project
}

data "kubernetes_namespace" "flux_namespace" {
  metadata {
    name = "flux-system"
  }
}