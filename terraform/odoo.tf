# Create ConfigMap for Odoo configuration
resource "kubernetes_config_map" "odoo" {
  for_each = local.client_env_map

  metadata {
    name      = "odoo-config"
    namespace = kubernetes_namespace.client_env[each.key].metadata[0].name
  }

  data = {
    "odoo.conf" = <<-EOT
      [options]
      db_host = postgres.${kubernetes_namespace.client_env[each.key].metadata[0].name}.svc.cluster.local
      db_user = ${var.postgres_user}
      db_password = ${var.postgres_password}
      db_port = ${var.postgres_port}
      db_name = ${var.postgres_db}
      addons_path = /mnt/extra-addons
      admin_passwd = admin
      EOT
  }
}

# Create Deployment for Odoo application
resource "kubernetes_deployment" "odoo" {
  for_each = local.client_env_map

  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.client_env[each.key].metadata[0].name
    labels = {
      app = "odoo"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "odoo"
      }
    }

    template {
      metadata {
        labels = {
          app = "odoo"
        }
      }

      spec {
        # Wait for postgres to be ready
        init_container {
          name  = "wait-for-db"
          image = "busybox:1.28"

          command = [
            "sh",
            "-c",
            "until nc -z postgres.${kubernetes_namespace.client_env[each.key].metadata[0].name}.svc.cluster.local ${var.postgres_port}; do echo waiting for db; sleep 2; done"
          ]
        }

        container {
          name  = "odoo"
          image = var.odoo_image

          port {
            container_port = var.odoo_port
            name           = "odoo"
          }

          env {
            name  = "VIRTUAL_HOST"
            value = local.domain_map[each.key]
          }

          env {
            name  = "DB_HOST"
            value = "postgres.${kubernetes_namespace.client_env[each.key].metadata[0].name}.svc.cluster.local"
          }

          env {
            name  = "DB_NAME"
            value = var.postgres_db
          }

          env {
            name  = "DB_USER"
            value = var.postgres_user
          }

          env {
            name  = "DB_PASSWORD"
            value = var.postgres_password
          }

          env {
            name  = "DB_PORT"
            value = tostring(var.postgres_port)
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
          }

          liveness_probe {
            http_get {
              path   = "/"
              port   = var.odoo_port
              scheme = "HTTP"
            }
            initial_delay_seconds = 60
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path   = "/"
              port   = var.odoo_port
              scheme = "HTTP"
            }
            initial_delay_seconds = 30
            period_seconds        = 5
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

# Create Service for Odoo application
resource "kubernetes_service" "odoo" {
  for_each = local.client_env_map

  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.client_env[each.key].metadata[0].name
  }

  spec {
    selector = {
      app = "odoo"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = var.odoo_port
      name        = "http"
    }

    port {
      protocol    = "TCP"
      port        = 443
      target_port = var.odoo_port
      name        = "https"
    }

    type = "ClusterIP"
  }
}

output "odoo_services" {
  description = "Odoo services"
  value = {
    for key, svc in kubernetes_service.odoo :
    key => "${svc.metadata[0].name}.${svc.metadata[0].namespace}"
  }
}
