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

# =============================================================================
# Environment 0 TLS Resources
# =============================================================================
resource "tls_private_key" "env_0_key" {
  count     = local.environment_count > 0 ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "env_0_csr" {
  count           = local.environment_count > 0 ? 1 : 0
  private_key_pem = tls_private_key.env_0_key[0].private_key_pem

  subject {
    common_name         = local.domain_names[0]
    organization        = local.client_name
    organizational_unit = local.environments[0]
  }

  dns_names = [local.domain_names[0]]
}

resource "tls_locally_signed_cert" "env_0_cert" {
  count              = local.environment_count > 0 ? 1 : 0
  cert_request_pem   = tls_cert_request.env_0_csr[0].cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "env_1_key" {
  count     = local.environment_count > 1 ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "env_1_csr" {
  count           = local.environment_count > 1 ? 1 : 0
  private_key_pem = tls_private_key.env_1_key[0].private_key_pem

  subject {
    common_name         = local.domain_names[1]
    organization        = local.client_name
    organizational_unit = local.environments[1]
  }

  dns_names = [local.domain_names[1]]
}

resource "tls_locally_signed_cert" "env_1_cert" {
  count              = local.environment_count > 1 ? 1 : 0
  cert_request_pem   = tls_cert_request.env_1_csr[0].cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}


resource "tls_private_key" "env_2_key" {
  count     = local.environment_count > 2 ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "env_2_csr" {
  count           = local.environment_count > 2 ? 1 : 0
  private_key_pem = tls_private_key.env_2_key[0].private_key_pem

  subject {
    common_name         = local.domain_names[2]
    organization        = local.client_name
    organizational_unit = local.environments[2]
  }

  dns_names = [local.domain_names[2]]
}

resource "tls_locally_signed_cert" "env_2_cert" {
  count              = local.environment_count > 2 ? 1 : 0
  cert_request_pem   = tls_cert_request.env_2_csr[0].cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}


resource "tls_private_key" "env_3_key" {
  count     = local.environment_count > 3 ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "env_3_csr" {
  count           = local.environment_count > 3 ? 1 : 0
  private_key_pem = tls_private_key.env_3_key[0].private_key_pem

  subject {
    common_name         = local.domain_names[3]
    organization        = local.client_name
    organizational_unit = local.environments[3]
  }

  dns_names = [local.domain_names[3]]
}

resource "tls_locally_signed_cert" "env_3_cert" {
  count              = local.environment_count > 3 ? 1 : 0
  cert_request_pem   = tls_cert_request.env_3_csr[0].cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
