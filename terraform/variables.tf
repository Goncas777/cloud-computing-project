variable "clients" {
  description = "Map of clients with their environments"
  type = map(object({
    environments = list(string)
  }))
  default = {
    airbnb = {
      environments = ["dev", "prod"]
    }
    nike = {
      environments = ["dev", "qa", "prod"]
    }
    mcdonalds = {
      environments = ["dev", "qa", "beta", "prod"]
    }
  }
}

variable "odoo_image" {
  description = "Docker image for Odoo application"
  type        = string
  default     = "odoo:16.0"
}

variable "odoo_port" {
  description = "Port for Odoo application"
  type        = number
  default     = 8069
}

variable "postgres_image" {
  description = "Docker image for PostgreSQL database"
  type        = string
  default     = "postgres:15-alpine"
}

variable "postgres_port" {
  description = "Port for PostgreSQL database"
  type        = number
  default     = 5432
}

variable "postgres_user" {
  description = "PostgreSQL user"
  type        = string
  default     = "odoo"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  default     = "odoo-password-123"
  sensitive   = true
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "odoo"
}

variable "tls_cert_validity_days" {
  description = "Validity period for self-signed TLS certificates in days"
  type        = number
  default     = 365
}

variable "minikube_driver" {
  description = "Minikube driver to use"
  type        = string
  default     = "docker"
}

variable "minikube_memory" {
  description = "Memory allocation for Minikube in MB"
  type        = number
  default     = 2048
}

variable "minikube_cpus" {
  description = "CPU allocation for Minikube"
  type        = number
  default     = 2
}

variable "kube_context" {
  description = "Kubernetes context to use (set via TF_VAR_kube_context)"
  type        = string
  default     = ""
}
