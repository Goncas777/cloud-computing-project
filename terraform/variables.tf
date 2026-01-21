variable "clients" {
  description = "Map of clients and their environments"
  type        = map(list(string))
}

variable "minikube_driver" {
  description = "Minikube driver (docker recommended)"
  type        = string
  default     = "docker"
}

variable "minikube_memory" {
  description = "Memory per cluster"
  type        = string
  default     = "2000m"
}

variable "minikube_force" {
  description = "Pass --force to minikube when running as root"
  type        = bool
  default     = true
}