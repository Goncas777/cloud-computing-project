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

variable "current_client" {
  description = "The current client being provisioned (must match Terraform workspace name)"
  type        = string
  default     = ""
}

variable "minikube_driver" {
  description = "Minikube driver to use"
  type        = string
  default     = "docker"
}

variable "minikube_cpus" {
  description = "Number of CPUs for Minikube cluster"
  type        = number
  default     = 2
}

variable "minikube_memory" {
  description = "Memory in MB for Minikube cluster"
  type        = number
  default     = 4096
}

variable "kubernetes_version" {
  description = "Kubernetes version for Minikube"
  type        = string
  default     = "v1.28.0"
}

variable "odoo_image" {
  description = "Odoo Docker image"
  type        = string
  default     = "odoo:16"
}

variable "postgres_image" {
  description = "PostgreSQL Docker image"
  type        = string
  default     = "postgres:15"
}

variable "odoo_replicas" {
  description = "Number of Odoo replicas per environment"
  type        = number
  default     = 1
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  default     = "odoo_password"
  sensitive   = true
}

variable "domain_suffix" {
  description = "Domain suffix for all applications"
  type        = string
  default     = "local"
}
