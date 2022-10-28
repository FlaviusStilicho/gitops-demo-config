data "kubernetes_namespace" "flux_namespace" {
  metadata {
    name = "flux-system"
  }
}

data "google_project" "current" {
  project_id = var.project_id
}

data "google_client_config" "provider" {}

resource "helm_release" "tf_controller" {
  chart      = "tf-controller"
  repository = "https://weaveworks.github.io/tf-controller/"
  name       = "tf-controller"
  namespace  = data.kubernetes_namespace.flux_namespace.metadata.0.name
}

resource "kubernetes_manifest" "demo_repo" {
  manifest = {
    apiVersion = "source.toolkit.fluxcd.io/v1beta1"
    kind       = "GitRepository"
    metadata   = {
      name      = "gitops-demo-app"
      namespace = data.kubernetes_namespace.flux_namespace.metadata.0.name
    }
    spec = {
      interval = "30s"
      url      = var.repository_url
      ref      = {
        branch = "master"
      }
    }
  }
}

resource "kubernetes_manifest" "demo_app" {
  manifest = {
    apiVersion = "infra.contrib.fluxcd.io/v1alpha1"
    kind       = "Terraform"
    metadata   = {
      name      = "gitops-demo-app"
      namespace = data.kubernetes_namespace.flux_namespace.metadata.0.name
    }
    spec = {
      interval    = "1m"
      approvePlan = "auto"
      path        = "/app"
      sourceRef   = {
        kind      = "GitRepository"
        name      = "gitops-demo-app"
        namespace = data.kubernetes_namespace.flux_namespace.metadata.0.name
      }
    }
  }
}

data "kubernetes_service_account" "tf_runner" {
  metadata {
    name = "tf-runner"
    namespace = "flux-system"
  }
}

data "google_iam_policy" "wli" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    members = [
      "serviceAccount:${data.google_project.current.project_id}.svc.id.goog[${data.kubernetes_namespace.flux_namespace.metadata[0].name}/${data.kubernetes_service_account.tf_runner.metadata.0.name}]"
    ]
  }
}

resource "google_service_account_iam_policy" "workloadIdentityUser" {
  service_account_id = google_service_account.flux_tf.name
  policy_data        = data.google_iam_policy.wli.policy_data
}

resource "google_service_account" "flux_tf" {
  account_id  = "flux-terraform"
}

resource "google_project_iam_member" "flux_tf" {
  role   = "roles/editor"
  project = var.project_id
  member = "serviceAccount:${google_service_account.flux_tf.email}"
}