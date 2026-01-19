# Generate self-signed TLS certificates for each domain
resource "tls_private_key" "odoo_key" {
  for_each = local.client_env_map

  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "odoo_cert" {
  for_each = local.client_env_map

  private_key_pem = tls_private_key.odoo_key[each.key].private_key_pem

  subject {
    common_name  = local.domain_map[each.key]
    organization = "Cloud Platform Engineering"
  }

  validity_period_hours = var.tls_cert_validity_days * 24

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Create Kubernetes Secrets with TLS certificates
resource "kubernetes_secret" "tls_cert" {
  for_each = local.client_env_map

  metadata {
    name      = "odoo-tls"
    namespace = kubernetes_namespace.client_env[each.key].metadata[0].name
  }

  data = {
    "tls.crt" = tls_self_signed_cert.odoo_cert[each.key].cert_pem
    "tls.key" = tls_private_key.odoo_key[each.key].private_key_pem
  }

  type = "kubernetes.io/tls"
}

# Create Ingress resources with HTTPS
resource "kubernetes_ingress_v1" "odoo" {
  for_each = local.client_env_map

  metadata {
    name      = "odoo-ingress"
    namespace = kubernetes_namespace.client_env[each.key].metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "ingress.kubernetes.io/ssl-redirect"         = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
    }
  }

  spec {
    tls {
      hosts = [local.domain_map[each.key]]
      secret_name = kubernetes_secret.tls_cert[each.key].metadata[0].name
    }

    rule {
      host = local.domain_map[each.key]

      http {
        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.odoo[each.key].metadata[0].name
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
}

output "tls_certificates" {
  description = "TLS certificate information"
  value = {
    for key, cert in tls_self_signed_cert.odoo_cert :
    key => {
      domain   = local.domain_map[key]
      cert_pem = cert.cert_pem
    }
  }
  sensitive = true
}

output "ingress_endpoints" {
  description = "Ingress endpoints for Odoo applications"
  value = {
    for key, ingress in kubernetes_ingress_v1.odoo :
    key => {
      namespace = ingress.metadata[0].namespace
      name      = ingress.metadata[0].name
      domain    = local.domain_map[key]
    }
  }
}
