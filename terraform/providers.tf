terraform {
  required_version = ">= 1.0.0"

  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "~> 0.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}


provider "minikube" {
  kubernetes_version = var.kubernetes_version
}


provider "kubernetes" {
  host                   = minikube_cluster.client_cluster.host
  client_certificate     = minikube_cluster.client_cluster.client_certificate
  client_key             = minikube_cluster.client_cluster.client_key
  cluster_ca_certificate = minikube_cluster.client_cluster.cluster_ca_certificate
}
