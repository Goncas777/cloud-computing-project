locals {

  workspace_name = terraform.workspace

  client_name = local.workspace_name != "default" ? local.workspace_name : var.current_client

  client_config = lookup(var.clients, local.client_name, null)

  environments = local.client_config != null ? local.client_config.environments : []

  environment_count = length(local.environments)

  namespace_names = [
    for env in local.environments : "${local.client_name}-${env}"
  ]


  domain_names = [
    for env in local.environments : "odoo.${env}.${local.client_name}.${var.domain_suffix}"
  ]

  cluster_name = "minikube-${local.client_name}"

  common_labels = {
    "managed-by" = "terraform"
    "client"     = local.client_name
    "project"    = "cloud-platform"
  }
}
