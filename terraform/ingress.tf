resource "kubernetes_ingress_v1" "odoo_env_0" {
  count = local.environment_count > 0 ? 1 : 0

  metadata {
    name      = "odoo-ingress"
    namespace = kubernetes_namespace.env_0[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = local.environments[0]
    })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"     = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [local.domain_names[0]]
      secret_name = kubernetes_secret.tls_env_0[0].metadata[0].name
    }

    rule {
      host = local.domain_names[0]

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.odoo_env_0[0].metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.odoo_env_0, kubernetes_secret.tls_env_0]
}

# Environment 1 Ingress
resource "kubernetes_ingress_v1" "odoo_env_1" {
  count = local.environment_count > 1 ? 1 : 0

  metadata {
    name      = "odoo-ingress"
    namespace = kubernetes_namespace.env_1[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = local.environments[1]
    })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"     = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [local.domain_names[1]]
      secret_name = kubernetes_secret.tls_env_1[0].metadata[0].name
    }

    rule {
      host = local.domain_names[1]

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.odoo_env_1[0].metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.odoo_env_1, kubernetes_secret.tls_env_1]
}

# Environment 2 Ingress
resource "kubernetes_ingress_v1" "odoo_env_2" {
  count = local.environment_count > 2 ? 1 : 0

  metadata {
    name      = "odoo-ingress"
    namespace = kubernetes_namespace.env_2[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = local.environments[2]
    })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"     = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [local.domain_names[2]]
      secret_name = kubernetes_secret.tls_env_2[0].metadata[0].name
    }

    rule {
      host = local.domain_names[2]

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.odoo_env_2[0].metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.odoo_env_2, kubernetes_secret.tls_env_2]
}

# Environment 3 Ingress
resource "kubernetes_ingress_v1" "odoo_env_3" {
  count = local.environment_count > 3 ? 1 : 0

  metadata {
    name      = "odoo-ingress"
    namespace = kubernetes_namespace.env_3[0].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = local.environments[3]
    })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"     = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [local.domain_names[3]]
      secret_name = kubernetes_secret.tls_env_3[0].metadata[0].name
    }

    rule {
      host = local.domain_names[3]

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.odoo_env_3[0].metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.odoo_env_3, kubernetes_secret.tls_env_3]
}
