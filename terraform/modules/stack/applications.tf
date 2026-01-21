# 1. Namespace
resource "kubernetes_namespace" "env" {
  metadata {
    name = "${var.client}-${var.environment}"
  }

  # Força o Terraform a esperar que o cluster (criado no main.tf) esteja pronto
  depends_on = [null_resource.minikube_cluster]
}

# 2. Segredo TLS (HTTPS)
resource "kubernetes_secret" "tls" {
  metadata {
    name      = "odoo-tls"
    namespace = kubernetes_namespace.env.metadata[0].name
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.cert.cert_pem
    "tls.key" = tls_private_key.pk.private_key_pem
  }
}

# 3. Credenciais da Base de Dados
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.env.metadata[0].name
  }

  type = "Opaque"

  data = {
    user     = "odoo"
    password = "odoo_strong_password"
    db       = "odoo"
  }
}

# 4. Base de Dados (StatefulSet)
resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.env.metadata[0].name
  }

  spec {
    service_name = "postgres"
    replicas     = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:15"

          port {
            container_port = 5432
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "user"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "db"
              }
            }
          }
        }
      }
    }
  }
}

# 5. Serviço DB (Headless)
resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.env.metadata[0].name
  }

  spec {
    cluster_ip = "None"

    ports {
      port = 5432
    }

    selector = {
      app = "postgres"
    }
  }
}

# 6. Aplicação Odoo (Deployment)
resource "kubernetes_deployment" "odoo" {
  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.env.metadata[0].name
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
        container {
          name  = "odoo"
          image = "odoo:16"

          port {
            container_port = 8069
          }

          env {
            name  = "HOST"
            value = "postgres"
          }

          env {
            name = "USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "user"
              }
            }
          }

          env {
            name = "PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "password"
              }
            }
          }
        }
      }
    }
  }
}

# 7. Serviço Odoo
resource "kubernetes_service" "odoo" {
  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.env.metadata[0].name
  }

  spec {
    type = "ClusterIP"

    ports {
      port        = 80
      target_port = 8069
    }

    selector = {
      app = "odoo"
    }
  }
}

# 8. Ingress (HTTPS)
resource "kubernetes_ingress_v1" "odoo_ingress" {
  metadata {
    name      = "odoo-ingress"
    namespace = kubernetes_namespace.env.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.domain]
      secret_name = kubernetes_secret.tls.metadata[0].name
    }

    rule {
      host = var.domain

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.odoo.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}