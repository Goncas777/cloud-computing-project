resource "kubernetes_namespace" "env_0" {
  count = local.environment_count > 0 ? 1 : 0

  metadata {
    name = local.namespace_names[0]
    labels = merge(local.common_labels, {
      "environment" = local.environments[0]
    })
  }

  depends_on = [minikube_cluster.client_cluster]
}

resource "kubernetes_namespace" "env_1" {
  count = local.environment_count > 1 ? 1 : 0

  metadata {
    name = local.namespace_names[1]
    labels = merge(local.common_labels, {
      "environment" = local.environments[1]
    })
  }

  depends_on = [minikube_cluster.client_cluster]
}

resource "kubernetes_namespace" "env_2" {
  count = local.environment_count > 2 ? 1 : 0

  metadata {
    name = local.namespace_names[2]
    labels = merge(local.common_labels, {
      "environment" = local.environments[2]
    })
  }

  depends_on = [minikube_cluster.client_cluster]
}

resource "kubernetes_namespace" "env_3" {
  count = local.environment_count > 3 ? 1 : 0

  metadata {
    name = local.namespace_names[3]
    labels = merge(local.common_labels, {
      "environment" = local.environments[3]
    })
  }

  depends_on = [minikube_cluster.client_cluster]
}
