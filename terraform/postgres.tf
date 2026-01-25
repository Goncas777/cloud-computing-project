resource "kubernetes_stateful_set" "postgres" {
  for_each = { for idx, env in local.environments : idx => env }

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.env[each.key].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "postgres"
      "environment" = each.value
    })
  }

  spec {
    service_name = "postgres"
    replicas     = 1

    selector {
      match_labels = {
        "app"         = "postgres"
        "environment" = each.value
      }
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          "app"         = "postgres"
          "environment" = each.value
        })
      }

      spec {
        container {
          name  = "postgres"
          image = var.postgres_image

          port {
            container_port = 5432
            name           = "postgres"
          }

          env {
            name  = "POSTGRES_DB"
            value = "postgres"
          }

          env {
            name  = "POSTGRES_USER"
            value = "odoo"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = var.postgres_password
          }

          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
            sub_path   = "data"
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "postgres-data"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "standard"

        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.env]
}

resource "kubernetes_service" "postgres" {
  for_each = { for idx, env in local.environments : idx => env }

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.env[each.key].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "postgres"
      "environment" = each.value
    })
  }

  spec {
    selector = {
      "app"         = "postgres"
      "environment" = each.value
    }

    port {
      port        = 5432
      target_port = 5432
    }

    cluster_ip = "None"
  }

  depends_on = [kubernetes_stateful_set.postgres]
}
