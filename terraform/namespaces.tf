resource "kubernetes_namespace" "env" {
  for_each = { for idx, env in local.environments : idx => env }

  metadata {
    name = local.namespace_names[each.key]
    labels = merge(local.common_labels, {
      "environment" = each.value
    })
  }

  depends_on = [minikube_cluster.client_cluster]
}
