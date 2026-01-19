# Minikube cluster provisioning for each client-environment combination

resource "minikube_cluster" "cluster" {
  for_each = local.client_env_map

  cluster_name = each.value.cluster_id
  driver       = var.minikube_driver
  memory       = var.minikube_memory
  cpus         = var.minikube_cpus

  # Enable required addons for ingress - must be a set of strings
  addons = toset([
    "default-storageclass",
    "storage-provisioner",
    "ingress"
  ])

  vm = true

  # Ensure minikube is cleaned up properly on destroy
  lifecycle {
    create_before_destroy = false
  }
}

output "minikube_clusters" {
  description = "Information about created Minikube clusters"
  value = {
    for key, cluster in minikube_cluster.cluster :
    key => {
      name = cluster.cluster_name
    }
  }
}
