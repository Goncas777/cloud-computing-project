module "clusters" {
  for_each = local.clusters

  source = "./modules/minikube-cluster"

  name = each.value.name
}


module "odoo" {
  for_each = {
    for env in local.environments : env.name => env
  }

  source = "./modules/odoo"

  client      = each.value.client
  environment = each.value.environment
  domain      = each.value.domain

  providers = {
    kubernetes = kubernetes[each.key]
  }
}

module "odoo_airbnb_dev" {
  source = "./modules/odoo"

  client      = "airbnb"
  environment = "dev"
  domain      = "odoo.dev.airbnb.local"

  providers = {
    kubernetes = kubernetes.airbnb_dev
  }
}

