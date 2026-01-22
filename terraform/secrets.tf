resource "kubernetes_secret" "tls_env_0" {
  count = local.environment_count > 0 ? 1 : 0

  metadata {
    name      = "tls-${local.environments[0]}"
    namespace = kubernetes_namespace.env_0[0].metadata[0].name
    labels = merge(local.common_labels, {
      "environment" = local.environments[0]
    })
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_locally_signed_cert.env_0_cert[0].cert_pem
    "tls.key" = tls_private_key.env_0_key[0].private_key_pem
  }

  depends_on = [kubernetes_namespace.env_0]
}

# Environment 1 TLS Secret
resource "kubernetes_secret" "tls_env_1" {
  count = local.environment_count > 1 ? 1 : 0

  metadata {
    name      = "tls-${local.environments[1]}"
    namespace = kubernetes_namespace.env_1[0].metadata[0].name
    labels = merge(local.common_labels, {
      "environment" = local.environments[1]
    })
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_locally_signed_cert.env_1_cert[0].cert_pem
    "tls.key" = tls_private_key.env_1_key[0].private_key_pem
  }

  depends_on = [kubernetes_namespace.env_1]
}

# Environment 2 TLS Secret
resource "kubernetes_secret" "tls_env_2" {
  count = local.environment_count > 2 ? 1 : 0

  metadata {
    name      = "tls-${local.environments[2]}"
    namespace = kubernetes_namespace.env_2[0].metadata[0].name
    labels = merge(local.common_labels, {
      "environment" = local.environments[2]
    })
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_locally_signed_cert.env_2_cert[0].cert_pem
    "tls.key" = tls_private_key.env_2_key[0].private_key_pem
  }

  depends_on = [kubernetes_namespace.env_2]
}

# Environment 3 TLS Secret
resource "kubernetes_secret" "tls_env_3" {
  count = local.environment_count > 3 ? 1 : 0

  metadata {
    name      = "tls-${local.environments[3]}"
    namespace = kubernetes_namespace.env_3[0].metadata[0].name
    labels = merge(local.common_labels, {
      "environment" = local.environments[3]
    })
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_locally_signed_cert.env_3_cert[0].cert_pem
    "tls.key" = tls_private_key.env_3_key[0].private_key_pem
  }

  depends_on = [kubernetes_namespace.env_3]
}
