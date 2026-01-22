output "client_name" {
  description = "Current client name"
  value       = local.client_name
}

output "environments" {
  description = "List of environments for this client"
  value       = local.environments
}

output "namespaces" {
  description = "List of namespace names created"
  value       = local.namespace_names
}

output "domain_names" {
  description = "List of domain names for Odoo applications"
  value       = local.domain_names
}

output "minikube_ip" {
  description = "Minikube cluster IP address"
  value       = minikube_cluster.client_cluster.host
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = "~/.kube/config"
}

output "access_urls" {
  description = "HTTPS URLs for accessing Odoo applications"
  value = [
    for domain in local.domain_names : "https://${domain}"
  ]
}

output "hosts_entries" {
  description = "Entries to add to /etc/hosts"
  value = join("\n", [
    for domain in local.domain_names : "${replace(replace(minikube_cluster.client_cluster.host, "https://", ""), ":8443", "")} ${domain}"
  ])
}
