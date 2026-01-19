# Default Kubernetes provider
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.kube_context
}

# Configure TLS provider (no iteration needed - one instance)
provider "tls" {}
