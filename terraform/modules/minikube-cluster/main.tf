resource "null_resource" "minikube" {
  provisioner "local-exec" {
    command = "minikube start -p ${var.name} --driver=docker --embed-certs=true"
  }

  lifecycle {
    prevent_destroy = false
  }

  provisioner "local-exec" {
    when    = destroy
    command = "minikube delete -p ${self.id}" # ou coloca nome fixo
  }
}
