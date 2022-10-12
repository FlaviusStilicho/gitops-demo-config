resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region
  project  = var.project_id

  #  network    = google_compute_network.vpc.name
  #  subnetwork = google_compute_subnetwork.subnet.name
  ip_allocation_policy {}
  # Enabling Autopilot for this cluster
  enable_autopilot = true
}

resource "kubernetes_namespace" "flux_namespace" {
  metadata {
    name = "flux-system"
  }
}