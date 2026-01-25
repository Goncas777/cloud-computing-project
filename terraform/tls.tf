resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Self-signed CA certificate
resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_key.private_key_pem

  subject {
    common_name         = "${local.client_name} CA"
    organization        = local.client_name
    organizational_unit = "Cloud Platform"
  }

  validity_period_hours = 87600 # 10 years
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
}

resource "tls_private_key" "env_key" {
  for_each  = { for idx, env in local.environments : idx => env }
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "env_csr" {
  for_each        = { for idx, env in local.environments : idx => env }
  private_key_pem = tls_private_key.env_key[each.key].private_key_pem

  subject {
    common_name         = local.domain_names[each.key]
    organization        = local.client_name
    organizational_unit = each.value
  }

  dns_names = [local.domain_names[each.key]]
}

resource "tls_locally_signed_cert" "env_cert" {
  for_each           = { for idx, env in local.environments : idx => env }
  cert_request_pem   = tls_cert_request.env_csr[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
