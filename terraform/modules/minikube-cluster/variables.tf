variable "name" {
  description = "Unique name of the Minikube cluster (client-environment)"
  type        = string
}

variable "driver" {
  description = "Minikube driver"
  type        = string
}

variable "memory" {
  description = "Memory per Minikube cluster"
  type        = string
}

variable "force" {
  description = "Whether to pass --force to minikube start"
  type        = bool
}
