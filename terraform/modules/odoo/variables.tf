variable "client" {
  description = "Client name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain" {
  description = "Domain for the Odoo instance (odoo.env.client.local)"
  type        = string
}
