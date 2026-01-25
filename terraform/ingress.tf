resource "kubernetes_ingress_v1" "odoo" {
  for_each = { for idx, env in local.environments : idx => env }

  metadata {
    name      = "odoo-ingress"
    namespace = kubernetes_namespace.env[each.key].metadata[0].name
    labels = merge(local.common_labels, {
      "app"         = "odoo"
      "environment" = each.value
    })
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"     = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [local.domain_names[each.key]]
      secret_name = kubernetes_secret.tls[each.key].metadata[0].name
    }

    rule {
      host = local.domain_names[each.key]

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.odoo[each.key].metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.odoo, kubernetes_secret.tls]
}
