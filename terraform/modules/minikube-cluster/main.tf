resource "null_resource" "minikube" {
  provisioner "local-exec" {
    command = <<EOT
minikube start -p ${var.name} \
  --driver=${var.driver} \
  --memory=${var.memory} \
  --embed-certs=true${var.force ? " --force" : ""}
minikube addons enable ingress -p ${var.name}
EOT
  }

  lifecycle {
    prevent_destroy = false
  }

  provisioner "local-exec" {
    when    = destroy
    command = "minikube delete -p ${self.id}" # ou coloca nome fixo
  }
}
