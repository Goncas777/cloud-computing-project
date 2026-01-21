locals {
  clusters = {
    for env in flatten([
      for client, envs in var.clients : [
        for e in envs : {
          client      = client
          environment = e
          name        = "${client}-${e}"
          domain      = "odoo.${e}.${client}.local"
        }
      ]
    ]) : env.name => env
  }
}
