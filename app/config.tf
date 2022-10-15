#terraform {
#  backend "gcs" {
#    bucket = "nc-alex-tf-state"
#    prefix = "gitops-demo-config"
#  }
#}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}