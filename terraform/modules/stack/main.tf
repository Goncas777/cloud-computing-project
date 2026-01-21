# 1. Provisionar Cluster Minikube
resource "null_resource" "minikube_cluster" {
  triggers = {
    cluster_name = var.cluster_name
  }

  # Cria o cluster e habilita o Ingress Controller (essencial para o Ingress funcionar)
  provisioner "local-exec" {
    command = <<EOT
      minikube start -p ${var.cluster_name} \
        --driver=${var.minikube_driver} \
        --memory=${var.minikube_memory} \
        --embed-certs=true
      
      minikube addons enable ingress -p ${var.cluster_name}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "minikube delete -p ${self.triggers.cluster_name}"
  }
}

# 2. Gerar Certificados TLS (Self-Signed)
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.pk.private_key_pem

  subject {
    common_name  = var.domain
    organization = "Cloud Engineering"
  }

  validity_period_hours = 8760
  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]
  dns_names             = [var.domain]
}

# 3. Gerar Manifestos Kubernetes (Templating)
# Usamos templatefile para injetar as variáveis dinâmicas no YAML
resource "local_file" "k8s_manifests" {
  content = templatefile("${path.root}/templates/manifests.yaml.tftpl", {
    namespace      = "${var.client}-${var.environment}"
    domain         = var.domain
    tls_crt_base64 = base64encode(tls_self_signed_cert.cert.cert_pem)
    tls_key_base64 = base64encode(tls_private_key.pk.private_key_pem)
  })
  filename = "${path.root}/.manifests/${var.cluster_name}.yaml"
}

# 4. Aplicar Recursos no Cluster
# Usamos 'minikube kubectl' para garantir que usamos o contexto correto deste cluster específico
resource "null_resource" "apply_manifests" {
  depends_on = [null_resource.minikube_cluster, local_file.k8s_manifests]

  triggers = {
    manifest_hash = local_file.k8s_manifests.content_sha256
  }

  provisioner "local-exec" {
    command = "minikube kubectl -- -p ${var.cluster_name} apply -f ${local_file.k8s_manifests.filename}"
  }
}