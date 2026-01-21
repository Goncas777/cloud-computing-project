output "current_client" {
  description = "Current client (workspace)"
  value       = local.current_client_name
}

output "cluster_name" {
  description = "Minikube cluster name for this client"
  value       = local.current_client_name
}

output "domain_map" {
  description = "Domain names per environment"
  value = {
    for env, data in local.environments : env => data.domain
  }
}