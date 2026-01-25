resource "kubernetes_secret" "tls" {
  for_each = { for idx, env in local.environments : idx => env }

  metadata {
    name      = "tls-${each.value}"
    namespace = kubernetes_namespace.env[each.key].metadata[0].name
    labels = merge(local.common_labels, {
      "environment" = each.value
    })
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_locally_signed_cert.env_cert[each.key].cert_pem
    "tls.key" = tls_private_key.env_key[each.key].private_key_pem
  }

  depends_on = [kubernetes_namespace.env]
}
