resource "kubernetes_deployment" "odoo_env_0" {
  count = local.environment_count > 0 ? 1 : 0

  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.env_0[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = local.environments[0]
    })
  }

  spec {
    replicas = var.odoo_replicas

    selector {
      match_labels = {
        "app"         = "odoo"
        "environment" = local.environments[0]
      }
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          "app"         = "odoo"
          "environment" = local.environments[0]
        })
      }

      spec {
        container {
          name  = "odoo"
          image = var.odoo_image

          port {
            container_port = 8069
            name           = "http"
          }

          env {
            name  = "HOST"
            value = "postgres"
          }

          env {
            name  = "PORT"
            value = "5432"
          }

          env {
            name  = "USER"
            value = "odoo"
          }

          env {
            name  = "PASSWORD"
            value = var.postgres_password
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "1"
            }
          }

          liveness_probe {
            tcp_socket {
              port = 8069
            }
            initial_delay_seconds = 180
            period_seconds        = 30
            timeout_seconds       = 10
            failure_threshold     = 6
          }

          readiness_probe {
            tcp_socket {
              port = 8069
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }
        }
      }
    }
  }

  timeouts {
    create = "15m"
    update = "15m"
  }

  depends_on = [kubernetes_stateful_set.postgres_env_0]
}


resource "kubernetes_service" "odoo_env_0" {
  count = local.environment_count > 0 ? 1 : 0

  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.env_0[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = local.environments[0]
    })
  }

  spec {
    selector = {
      "app"         = "odoo"
      "environment" = local.environments[0]
    }

    port {
      port        = 80
      target_port = 8069
      name        = "http"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.odoo_env_0]
}


resource "kubernetes_deployment" "odoo_env_1" {
  count = local.environment_count > 1 ? 1 : 0

  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.env_1[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = local.environments[1]
    })
  }

  spec {
    replicas = var.odoo_replicas

    selector {
      match_labels = {
        "app"         = "odoo"
        "environment" = local.environments[1]
      }
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          "app"         = "odoo"
          "environment" = local.environments[1]
        })
      }

      spec {
        container {
          name  = "odoo"
          image = var.odoo_image

          port {
            container_port = 8069
            name           = "http"
          }

          env {
            name  = "HOST"
            value = "postgres"
          }

          env {
            name  = "PORT"
            value = "5432"
          }

          env {
            name  = "USER"
            value = "odoo"
          }

          env {
            name  = "PASSWORD"
            value = var.postgres_password
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "1"
            }
          }

          liveness_probe {
            tcp_socket {
              port = 8069
            }
            initial_delay_seconds = 180
            period_seconds        = 30
            timeout_seconds       = 10
            failure_threshold     = 6
          }

          readiness_probe {
            tcp_socket {
              port = 8069
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }
        }
      }
    }
  }

  timeouts {
    create = "15m"
    update = "15m"
  }

  depends_on = [kubernetes_stateful_set.postgres_env_1]
}

resource "kubernetes_service" "odoo_env_1" {
  count = local.environment_count > 1 ? 1 : 0

  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.env_1[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = local.environments[1]
    })
  }

  spec {
    selector = {
      "app"         = "odoo"
      "environment" = local.environments[1]
    }

    port {
      port        = 80
      target_port = 8069
      name        = "http"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.odoo_env_1]
}

resource "kubernetes_deployment" "odoo_env_2" {
  count = local.environment_count > 2 ? 1 : 0

  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.env_2[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = local.environments[2]
    })
  }

  spec {
    replicas = var.odoo_replicas

    selector {
      match_labels = {
        "app"         = "odoo"
        "environment" = local.environments[2]
      }
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          "app"         = "odoo"
          "environment" = local.environments[2]
        })
      }

      spec {
        container {
          name  = "odoo"
          image = var.odoo_image

          port {
            container_port = 8069
            name           = "http"
          }

          env {
            name  = "HOST"
            value = "postgres"
          }

          env {
            name  = "PORT"
            value = "5432"
          }

          env {
            name  = "USER"
            value = "odoo"
          }

          env {
            name  = "PASSWORD"
            value = var.postgres_password
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "1"
            }
          }

          liveness_probe {
            tcp_socket {
              port = 8069
            }
            initial_delay_seconds = 180
            period_seconds        = 30
            timeout_seconds       = 10
            failure_threshold     = 6
          }

          readiness_probe {
            tcp_socket {
              port = 8069
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }
        }
      }
    }
  }

  timeouts {
    create = "15m"
    update = "15m"
  }

  depends_on = [kubernetes_stateful_set.postgres_env_2]
}

resource "kubernetes_service" "odoo_env_2" {
  count = local.environment_count > 2 ? 1 : 0

  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.env_2[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = local.environments[2]
    })
  }

  spec {
    selector = {
      "app"         = "odoo"
      "environment" = local.environments[2]
    }

    port {
      port        = 80
      target_port = 8069
      name        = "http"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.odoo_env_2]
}

# =============================================================================
# Environment 3 Odoo
# =============================================================================
resource "kubernetes_deployment" "odoo_env_3" {
  count = local.environment_count > 3 ? 1 : 0

  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.env_3[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = local.environments[3]
    })
  }

  spec {
    replicas = var.odoo_replicas

    selector {
      match_labels = {
        "app"         = "odoo"
        "environment" = local.environments[3]
      }
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          "app"         = "odoo"
          "environment" = local.environments[3]
        })
      }

      spec {
        container {
          name  = "odoo"
          image = var.odoo_image

          port {
            container_port = 8069
            name           = "http"
          }

          env {
            name  = "HOST"
            value = "postgres"
          }

          env {
            name  = "PORT"
            value = "5432"
          }

          env {
            name  = "USER"
            value = "odoo"
          }

          env {
            name  = "PASSWORD"
            value = var.postgres_password
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "1"
            }
          }

          liveness_probe {
            tcp_socket {
              port = 8069
            }
            initial_delay_seconds = 180
            period_seconds        = 30
            timeout_seconds       = 10
            failure_threshold     = 6
          }

          readiness_probe {
            tcp_socket {
              port = 8069
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }
        }
      }
    }
  }

  timeouts {
    create = "15m"
    update = "15m"
  }

  depends_on = [kubernetes_stateful_set.postgres_env_3]
}

resource "kubernetes_service" "odoo_env_3" {
  count = local.environment_count > 3 ? 1 : 0

  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.env_3[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = local.environments[3]
    })
  }

  spec {
    selector = {
      "app"         = "odoo"
      "environment" = local.environments[3]
    }

    port {
      port        = 80
      target_port = 8069
      name        = "http"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.odoo_env_3]
}
