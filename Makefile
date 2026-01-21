.PHONY: init workspace apply destroy validate update-hosts

CLIENT ?= airbnb

init:
	terraform init

workspace:
	@terraform workspace new $(CLIENT) 2>/dev/null || terraform workspace select $(CLIENT)

apply: workspace
	@echo "Deploying infrastructure for client: $(CLIENT)"
	terraform apply -var-file="terraform.tfvars" -auto-approve
	@$(MAKE) update-hosts

destroy: workspace
	@echo "Destroying infrastructure for client: $(CLIENT)"
	terraform destroy -auto-approve
	# Limpar /etc/hosts manualmente seria ideal aqui, mas o script de update já limpa na próxima execução

update-hosts:
	@chmod +x scripts/update_hosts.sh
	@./scripts/update_hosts.sh

validate:
	@chmod +x scripts/validate.sh
	@./scripts/validate.sh