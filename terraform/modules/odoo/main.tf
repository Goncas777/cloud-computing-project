
# Namespace
resource "kubernetes_namespace" "odoo_ns" {
  metadata {
    name = "${var.client}-${var.environment}"
  }
}

resource "tls_private_key" "odoo_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}


resource "tls_self_signed_cert" "odoo_cert" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.odoo_key.private_key_pem
  subject {
    common_name  = var.domain
    organization = ["Terraform Odoo"]
  }
  validity_period_hours = 8760 # 1 ano
  dns_names             = [var.domain]
}

resource "kubernetes_secret" "tls_secret" {
  metadata {
    name      = "odoo-tls"
    namespace = kubernetes_namespace.odoo_ns.metadata[0].name
  }

  type = "kubernetes.io/tls"

  data = {
    tls.crt = tls_self_signed_cert.odoo_cert.cert_pem
    tls.key = tls_private_key.odoo_key.private_key_pem
  }
}

# StatefulSet: Postgres DB
resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.odoo_ns.metadata[0].name
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
          image = "postgres:14"

          env {
            name  = "POSTGRES_PASSWORD"
            value = "odoo123" # apenas para teste
          }

          port {
            container_port = 5432
          }
        }
      }
    }
  }
}

# Deployment: Odoo
resource "kubernetes_deployment" "odoo" {
  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace.odoo_ns.metadata[0].name
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

          env {
            name  = "DB_HOST"
            value = "postgres.${kubernetes_namespace.odoo_ns.metadata[0].name}.svc.cluster.local"
          }

          env {
            name  = "DB_PASSWORD"
            value = "odoo123"
          }

          port {
            container_port = 8069
          }
        }
      }
    }
  }
}

# Service Odoo
resource "kubernetes_service" "odoo_svc" {
  metadata {
    name      = "odoo-service"
    namespace = kubernetes_namespace.odoo_ns.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.odoo.spec[0].template[0].metadata[0].labels["app"]
    }

    port {
      port        = 80
      target_port = 8069
    }

    type = "ClusterIP"
  }
}

# Ingress HTTPS
resource "kubernetes_ingress_v1" "odoo_ingress" {
  metadata {
    name      = "odoo-ingress"
    namespace = kubernetes_namespace.odoo_ns.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    tls {
      hosts      = [var.domain]
      secret_name = kubernetes_secret.tls_secret.metadata[0].name
    }

    rule {
      host = var.domain

      http {
        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.odoo_svc.metadata[0].name
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
