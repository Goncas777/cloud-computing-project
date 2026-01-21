output "odoo_namespace" {
  value = kubernetes_namespace.odoo_ns.metadata[0].name
}

output "odoo_domain" {
  value = var.domain
}
