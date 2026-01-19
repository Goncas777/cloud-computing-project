# Flatten clients and environments into a list of tuples for easier iteration
locals {
  # Create a flat list of all client-environment combinations
  client_environments = flatten([
    for client_name, client_config in var.clients : [
      for env in client_config.environments : {
        client      = client_name
        environment = env
        cluster_id  = "${client_name}-${env}"
      }
    ]
  ])

  # Convert to map for easier access in resource references
  client_env_map = {
    for item in local.client_environments :
    "${item.client}-${item.environment}" => item
  }

  # Create domain names for each environment
  domain_map = {
    for item in local.client_environments :
    "${item.client}-${item.environment}" => "odoo.${item.environment}.${item.client}.local"
  }
}

# Output for debugging
output "client_environments" {
  description = "All client-environment combinations"
  value       = local.client_env_map
}

output "domain_map" {
  description = "Domain mappings"
  value       = local.domain_map
}
