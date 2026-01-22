resource "kubernetes_stateful_set" "postgres_env_0" {
  count = local.environment_count > 0 ? 1 : 0

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.env_0[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "postgres"
      "environment" = local.environments[0]
    })
  }

  spec {
    service_name = "postgres"
    replicas     = 1

    selector {
      match_labels = {
        "app"         = "postgres"
        "environment" = local.environments[0]
      }
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          "app"         = "postgres"
          "environment" = local.environments[0]
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

  depends_on = [kubernetes_namespace.env_0]
}

# Environment 0 PostgreSQL Service
resource "kubernetes_service" "postgres_env_0" {
  count = local.environment_count > 0 ? 1 : 0

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.env_0[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "postgres"
      "environment" = local.environments[0]
    })
  }

  spec {
    selector = {
      "app"         = "postgres"
      "environment" = local.environments[0]
    }

    port {
      port        = 5432
      target_port = 5432
    }

    cluster_ip = "None"
  }

  depends_on = [kubernetes_stateful_set.postgres_env_0]
}

# =============================================================================
# Environment 1 PostgreSQL
# =============================================================================
resource "kubernetes_stateful_set" "postgres_env_1" {
  count = local.environment_count > 1 ? 1 : 0

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.env_1[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "postgres"
      "environment" = local.environments[1]
    })
  }

  spec {
    service_name = "postgres"
    replicas     = 1

    selector {
      match_labels = {
        "app"         = "postgres"
        "environment" = local.environments[1]
      }
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          "app"         = "postgres"
          "environment" = local.environments[1]
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

  depends_on = [kubernetes_namespace.env_1]
}

resource "kubernetes_service" "postgres_env_1" {
  count = local.environment_count > 1 ? 1 : 0

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.env_1[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "postgres"
      "environment" = local.environments[1]
    })
  }

  spec {
    selector = {
      "app"         = "postgres"
      "environment" = local.environments[1]
    }

    port {
      port        = 5432
      target_port = 5432
    }

    cluster_ip = "None"
  }

  depends_on = [kubernetes_stateful_set.postgres_env_1]
}

# =============================================================================
# Environment 2 PostgreSQL
# =============================================================================
resource "kubernetes_stateful_set" "postgres_env_2" {
  count = local.environment_count > 2 ? 1 : 0

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.env_2[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "postgres"
      "environment" = local.environments[2]
    })
  }

  spec {
    service_name = "postgres"
    replicas     = 1

    selector {
      match_labels = {
        "app"         = "postgres"
        "environment" = local.environments[2]
      }
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          "app"         = "postgres"
          "environment" = local.environments[2]
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

  depends_on = [kubernetes_namespace.env_2]
}

resource "kubernetes_service" "postgres_env_2" {
  count = local.environment_count > 2 ? 1 : 0

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.env_2[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "postgres"
      "environment" = local.environments[2]
    })
  }

  spec {
    selector = {
      "app"         = "postgres"
      "environment" = local.environments[2]
    }

    port {
      port        = 5432
      target_port = 5432
    }

    cluster_ip = "None"
  }

  depends_on = [kubernetes_stateful_set.postgres_env_2]
}

# =============================================================================
# Environment 3 PostgreSQL
# =============================================================================
resource "kubernetes_stateful_set" "postgres_env_3" {
  count = local.environment_count > 3 ? 1 : 0

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.env_3[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "postgres"
      "environment" = local.environments[3]
    })
  }

  spec {
    service_name = "postgres"
    replicas     = 1

    selector {
      match_labels = {
        "app"         = "postgres"
        "environment" = local.environments[3]
      }
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          "app"         = "postgres"
          "environment" = local.environments[3]
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

  depends_on = [kubernetes_namespace.env_3]
}

resource "kubernetes_service" "postgres_env_3" {
  count = local.environment_count > 3 ? 1 : 0

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.env_3[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "postgres"
      "environment" = local.environments[3]
    })
  }

  spec {
    selector = {
      "app"         = "postgres"
      "environment" = local.environments[3]
    }

    port {
      port        = 5432
      target_port = 5432
    }

    cluster_ip = "None"
  }

  depends_on = [kubernetes_stateful_set.postgres_env_3]
}
