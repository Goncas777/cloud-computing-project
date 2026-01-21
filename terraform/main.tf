locals {
  # Seleciona o cliente com base no workspace atual (ex: 'default', 'airbnb')
  # Se estiver no default, não faz nada para evitar erros.
  current_client_name = terraform.workspace
  current_envs        = lookup(var.clients, local.current_client_name, [])

  # Cria uma lista de objetos para o loop
  environments = {
    for env in local.current_envs : env => {
      client      = local.current_client_name
      environment = env
      # Nome do Cluster: client
      cluster_name = local.current_client_name
      # Domínio: odoo.env.client.local
      domain = "odoo.${env}.${local.current_client_name}.local"
    }
  }
}

module "cluster" {
  source = "./modules/minikube-cluster"
  count  = local.current_client_name == "default" ? 0 : 1

  name   = local.current_client_name
  driver = var.minikube_driver
  memory = var.minikube_memory
  force  = var.minikube_force
}

module "odoo" {
  for_each = local.environments

  source = "./modules/odoo"

  client      = each.value.client
  environment = each.value.environment
  domain      = each.value.domain

  depends_on = [module.cluster]
}