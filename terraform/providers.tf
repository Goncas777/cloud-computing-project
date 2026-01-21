terraform {
  required_version = ">= 1.3.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
  }
}

provider "kubernetes" {
  for_each = {
    for env in local.environments : env.name => env
  }

  alias          = each.key
  config_path   = pathexpand("~/.kube/config")
  config_context = each.key
}

terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
