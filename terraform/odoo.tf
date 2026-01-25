resource "kubernetes_deployment" "odoo" {
  for_each = { for idx, env in local.environments : idx => env }

  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.env[each.key].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = each.value
    })
  }

  spec {
    replicas = var.odoo_replicas

    selector {
      match_labels = {
        "app"         = "odoo"
        "environment" = each.value
      }
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          "app"         = "odoo"
          "environment" = each.value
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

  depends_on = [kubernetes_stateful_set.postgres]
}

resource "kubernetes_service" "odoo" {
  for_each = { for idx, env in local.environments : idx => env }

  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.env[each.key].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = each.value
    })
  }

  spec {
    selector = {
      "app"         = "odoo"
      "environment" = each.value
    }

    port {
      port        = 80
      target_port = 8069
      name        = "http"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.odoo]
}
