# Create Kubernetes namespaces for each client-environment combination
resource "kubernetes_namespace" "client_env" {
  for_each = local.client_env_map

  metadata {
    name = "${each.value.client}-${each.value.environment}"
    labels = {
      client      = each.value.client
      environment = each.value.environment
      managed_by  = "terraform"
    }
  }
}

output "namespaces" {
  description = "Created Kubernetes namespaces"
  value = {
    for key, ns in kubernetes_namespace.client_env :
    key => ns.metadata[0].name
  }
}
