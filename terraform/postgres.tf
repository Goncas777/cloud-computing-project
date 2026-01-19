# Create storage class for persistent volumes
resource "kubernetes_storage_class" "postgres" {
  for_each = local.client_env_map

  metadata {
    name = "postgres-storage-${each.value.environment}"
  }

  storage_provisioner = "k8s.io/minikube-hostpath"
  reclaim_policy      = "Delete"
}

# Create Secret for PostgreSQL credentials
resource "kubernetes_secret" "postgres" {
  for_each = local.client_env_map

  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace.client_env[each.key].metadata[0].name
  }

  data = {
    POSTGRES_USER     = var.postgres_user
    POSTGRES_PASSWORD = var.postgres_password
    POSTGRES_DB       = var.postgres_db
  }

  type = "Opaque"
}

# Create PersistentVolumeClaim for PostgreSQL
resource "kubernetes_persistent_volume_claim" "postgres" {
  for_each = local.client_env_map

  metadata {
    name      = "postgres-pvc"
    namespace = kubernetes_namespace.client_env[each.key].metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "5Gi"
      }
    }

    storage_class_name = kubernetes_storage_class.postgres[each.key].metadata[0].name
  }
}

# Create StatefulSet for PostgreSQL database
resource "kubernetes_stateful_set" "postgres" {
  for_each = local.client_env_map

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.client_env[each.key].metadata[0].name
    labels = {
      app = "postgres"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "postgres"
      }
    }

    service_name = "postgres"

    replicas = 1

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = var.postgres_image

          port {
            container_port = var.postgres_port
            name           = "postgres"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.postgres[each.key].metadata[0].name
            }
          }

          volume_mount {
            name              = "postgres-data"
            mount_path        = "/var/lib/postgresql/data"
            sub_path          = "postgres"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            exec {
              command = ["pg_isready", "-U", var.postgres_user, "-d", var.postgres_db]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            exec {
              command = ["pg_isready", "-U", var.postgres_user, "-d", var.postgres_db]
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }

        volume {
          name = "postgres-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres[each.key].metadata[0].name
          }
        }
      }
    }
  }
}

# Create Headless Service for StatefulSet
resource "kubernetes_service" "postgres" {
  for_each = local.client_env_map

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.client_env[each.key].metadata[0].name
  }

  spec {
    selector = {
      app = "postgres"
    }

    cluster_ip = "None"

    port {
      protocol    = "TCP"
      port        = var.postgres_port
      target_port = var.postgres_port
    }

    type = "ClusterIP"
  }
}

output "postgres_services" {
  description = "PostgreSQL services"
  value = {
    for key, svc in kubernetes_service.postgres :
    key => svc.metadata[0].name
  }
}
