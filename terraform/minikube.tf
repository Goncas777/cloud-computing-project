resource "minikube_cluster" "client_cluster" {
  cluster_name = local.cluster_name
  driver       = var.minikube_driver
  cpus         = var.minikube_cpus
  memory       = var.minikube_memory

  addons = [
    "default-storageclass",
    "storage-provisioner",
    "ingress"
  ]

  wait = ["all"]
}

output "cluster_name" {
  description = "Name of the Minikube cluster"
  value       = minikube_cluster.client_cluster.cluster_name
}

output "cluster_host" {
  description = "Kubernetes API server host"
  value       = minikube_cluster.client_cluster.host
}

output "cluster_ip" {
  description = "Minikube cluster IP address"
  value       = minikube_cluster.client_cluster.host
}
