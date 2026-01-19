.PHONY: help init plan apply destroy validate clean logs bootstrap
.DEFAULT_GOAL := help

TERRAFORM_DIR := terraform
SCRIPTS_DIR := scripts
STATE_DIR := .terraform

help: ## Display this help message
	@echo "Cloud Computing Platform - Terraform Infrastructure"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform working directory
	@echo "Initializing Terraform..."
	cd $(TERRAFORM_DIR) && terraform init

validate: ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	cd $(TERRAFORM_DIR) && terraform validate

plan: init validate ## Create Terraform execution plan
	@echo "Creating Terraform plan..."
	cd $(TERRAFORM_DIR) && terraform plan -out=tfplan

apply: init validate ## Apply Terraform configuration (creates all infrastructure)
	@echo "Applying Terraform configuration..."
	@echo "This will create all Kubernetes clusters and applications..."
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve
	@echo ""
	@echo "✓ Infrastructure deployment complete!"
	@echo ""
	$(MAKE) post-apply

post-apply: ## Post-apply actions (update /etc/hosts, display access info)
	@echo "Running post-apply configuration..."
	@bash $(SCRIPTS_DIR)/update_hosts.sh
	@echo ""
	@echo "✓ /etc/hosts updated with domain mappings"

destroy: ## Destroy all infrastructure
	@echo "WARNING: This will destroy all Kubernetes clusters and infrastructure"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
	@sleep 5
	@echo "Destroying infrastructure..."
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve
	@echo "✓ Infrastructure destroyed"

refresh: ## Refresh Terraform state
	@echo "Refreshing Terraform state..."
	cd $(TERRAFORM_DIR) && terraform refresh

output: ## Display Terraform outputs
	@echo "Terraform Outputs:"
	@echo "===================="
	cd $(TERRAFORM_DIR) && terraform output

plan-destroy: ## Show what would be destroyed
	@echo "Planning destruction..."
	cd $(TERRAFORM_DIR) && terraform plan -destroy

bootstrap: ## Bootstrap environment and create infrastructure
	@echo "Bootstrap process starting..."
	@echo "Step 1: Initializing Terraform..."
	$(MAKE) init
	@echo ""
	@echo "Step 2: Validating configuration..."
	$(MAKE) validate
	@echo ""
	@echo "Step 3: Applying infrastructure..."
	$(MAKE) apply
	@echo ""
	@echo "✓ Bootstrap complete!"

clean: ## Clean Terraform state and cache
	@echo "Cleaning Terraform state..."
	cd $(TERRAFORM_DIR) && rm -rf .terraform tfplan .terraform.lock.hcl
	@echo "✓ Cleanup complete"

clean-all: destroy clean ## Complete cleanup - destroy and clean state

fmt: ## Format Terraform code
	@echo "Formatting Terraform code..."
	cd $(TERRAFORM_DIR) && terraform fmt -recursive

validate-deployment: ## Validate all deployed applications with curl
	@echo "Validating deployments..."
	@bash $(SCRIPTS_DIR)/validate_deployments.sh

logs-all: ## Display logs from all Odoo deployments
	@echo "Displaying Odoo application logs..."
	@bash $(SCRIPTS_DIR)/get_logs.sh

status: ## Display status of all clusters and deployments
	@echo "Cluster and Deployment Status"
	@echo "=============================="
	@bash $(SCRIPTS_DIR)/status.sh

kubeconfig: ## Display kubeconfig location and usage info
	@echo "Kubernetes Configuration Information"
	@echo "====================================="
	@bash $(SCRIPTS_DIR)/show_kubeconfig.sh

access-info: ## Display access information for all applications
	@echo "Application Access Information"
	@echo "==============================="
	@bash $(SCRIPTS_DIR)/access_info.sh

.PHONY: test
test: ## Run basic tests on infrastructure
	@echo "Running infrastructure tests..."
	@bash $(SCRIPTS_DIR)/test.sh

upgrade-tf: ## Upgrade Terraform providers
	@echo "Upgrading Terraform providers..."
	cd $(TERRAFORM_DIR) && terraform init -upgrade

get-cluster-ips: ## Get IP addresses of all Minikube clusters
	@echo "Minikube Cluster IPs"
	@echo "===================="
	@bash $(SCRIPTS_DIR)/get_cluster_ips.sh

graph: ## Generate Terraform resource graph
	@echo "Generating Terraform graph..."
	cd $(TERRAFORM_DIR) && terraform graph > graph.dot
	@echo "Graph saved to $(TERRAFORM_DIR)/graph.dot"
	@echo "View with: dot -Tpng $(TERRAFORM_DIR)/graph.dot -o $(TERRAFORM_DIR)/graph.png"

debug: ## Enable debug logging for Terraform
	@echo "Enabling debug mode for Terraform..."
	@export TF_LOG=DEBUG
	@echo "DEBUG mode enabled. Run terraform commands with TF_LOG=DEBUG prefix"

# Targeted deployment commands
apply-target: ## Apply specific resource (usage: make apply-target TARGET='minikube_cluster.cluster["airbnb-dev"]')
	@if [ -z "$(TARGET)" ]; then \
		echo "Error: TARGET is required"; \
		echo "Usage: make apply-target TARGET='minikube_cluster.cluster[\"airbnb-dev\"]'"; \
		exit 1; \
	fi
	@echo "Applying target: $(TARGET)"
	cd $(TERRAFORM_DIR) && TF_VAR_kube_context="$${KUBE_CONTEXT:-$$(kubectl config current-context)}" terraform apply -target='$(TARGET)' -auto-approve

plan-target: ## Plan specific resource (usage: make plan-target TARGET='minikube_cluster.cluster["airbnb-dev"]')
	@if [ -z "$(TARGET)" ]; then \
		echo "Error: TARGET is required"; \
		echo "Usage: make plan-target TARGET='minikube_cluster.cluster[\"airbnb-dev\"]'"; \
		exit 1; \
	fi
	@echo "Planning target: $(TARGET)"
	cd $(TERRAFORM_DIR) && terraform plan -target='$(TARGET)'

# Individual client-environment deployments
apply-airbnb-dev: ## Deploy AirBnB development environment
	@echo "Deploying AirBnB Development Environment..."
	$(MAKE) apply-target TARGET='minikube_cluster.cluster["airbnb-dev"]'
	@echo "Configuring kubectl for airbnb-dev cluster..."
	@minikube update-context -p airbnb-dev || true
	@kubectl config use-context airbnb-dev || true
	$(MAKE) apply-target TARGET='kubernetes_namespace.client_env["airbnb-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_storage_class.postgres["airbnb-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_secret.postgres["airbnb-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_persistent_volume_claim.postgres["airbnb-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_stateful_set.postgres["airbnb-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_service.postgres["airbnb-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_config_map.odoo["airbnb-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_deployment.odoo["airbnb-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_service.odoo["airbnb-dev"]'
	$(MAKE) apply-target TARGET='tls_private_key.odoo_key["airbnb-dev"]'
	$(MAKE) apply-target TARGET='tls_self_signed_cert.odoo_cert["airbnb-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_secret.tls_cert["airbnb-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_ingress_v1.odoo["airbnb-dev"]'
	@echo "✓ AirBnB Dev deployment complete!"

apply-airbnb-prod: ## Deploy AirBnB production environment
	@echo "Deploying AirBnB Production Environment..."
	$(MAKE) apply-target TARGET='minikube_cluster.cluster["airbnb-prod"]'
	@echo "Configuring kubectl for airbnb-prod cluster..."
	@minikube update-context -p airbnb-prod || true
	@kubectl config use-context airbnb-prod || true
	$(MAKE) apply-target TARGET='kubernetes_namespace.client_env["airbnb-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_storage_class.postgres["airbnb-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_secret.postgres["airbnb-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_persistent_volume_claim.postgres["airbnb-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_stateful_set.postgres["airbnb-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_service.postgres["airbnb-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_config_map.odoo["airbnb-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_deployment.odoo["airbnb-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_service.odoo["airbnb-prod"]'
	$(MAKE) apply-target TARGET='tls_private_key.odoo_key["airbnb-prod"]'
	$(MAKE) apply-target TARGET='tls_self_signed_cert.odoo_cert["airbnb-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_secret.tls_cert["airbnb-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_ingress_v1.odoo["airbnb-prod"]'
	@echo "✓ AirBnB Prod deployment complete!"

apply-nike-dev: ## Deploy Nike development environment
	@echo "Deploying Nike Development Environment..."
	$(MAKE) apply-target TARGET='minikube_cluster.cluster["nike-dev"]'
	@echo "Configuring kubectl for nike-dev cluster..."
	@minikube update-context -p nike-dev || true
	@kubectl config use-context nike-dev || true
	$(MAKE) apply-target TARGET='kubernetes_namespace.client_env["nike-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_storage_class.postgres["nike-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_secret.postgres["nike-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_persistent_volume_claim.postgres["nike-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_stateful_set.postgres["nike-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_service.postgres["nike-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_config_map.odoo["nike-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_deployment.odoo["nike-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_service.odoo["nike-dev"]'
	$(MAKE) apply-target TARGET='tls_private_key.odoo_key["nike-dev"]'
	$(MAKE) apply-target TARGET='tls_self_signed_cert.odoo_cert["nike-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_secret.tls_cert["nike-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_ingress_v1.odoo["nike-dev"]'
	@echo "✓ Nike Dev deployment complete!"

apply-nike-prod: ## Deploy Nike production environment
	@echo "Deploying Nike Production Environment..."
	$(MAKE) apply-target TARGET='minikube_cluster.cluster["nike-prod"]'
	@echo "Configuring kubectl for nike-prod cluster..."
	@minikube update-context -p nike-prod || true
	@kubectl config use-context nike-prod || true
	$(MAKE) apply-target TARGET='kubernetes_namespace.client_env["nike-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_storage_class.postgres["nike-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_secret.postgres["nike-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_persistent_volume_claim.postgres["nike-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_stateful_set.postgres["nike-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_service.postgres["nike-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_config_map.odoo["nike-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_deployment.odoo["nike-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_service.odoo["nike-prod"]'
	$(MAKE) apply-target TARGET='tls_private_key.odoo_key["nike-prod"]'
	$(MAKE) apply-target TARGET='tls_self_signed_cert.odoo_cert["nike-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_secret.tls_cert["nike-prod"]'
	$(MAKE) apply-target TARGET='kubernetes_ingress_v1.odoo["nike-prod"]'
	@echo "✓ Nike Prod deployment complete!"

apply-mcdonalds-dev: ## Deploy McDonalds development environment
	@echo "Deploying McDonalds Development Environment..."
	$(MAKE) apply-target TARGET='minikube_cluster.cluster["mcdonalds-dev"]'
	@echo "Configuring kubectl for mcdonalds-dev cluster..."
	@minikube update-context -p mcdonalds-dev || true
	@kubectl config use-context mcdonalds-dev || true
	$(MAKE) apply-target TARGET='kubernetes_namespace.client_env["mcdonalds-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_storage_class.postgres["mcdonalds-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_secret.postgres["mcdonalds-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_persistent_volume_claim.postgres["mcdonalds-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_stateful_set.postgres["mcdonalds-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_service.postgres["mcdonalds-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_config_map.odoo["mcdonalds-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_deployment.odoo["mcdonalds-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_service.odoo["mcdonalds-dev"]'
	$(MAKE) apply-target TARGET='tls_private_key.odoo_key["mcdonalds-dev"]'
	$(MAKE) apply-target TARGET='tls_self_signed_cert.odoo_cert["mcdonalds-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_secret.tls_cert["mcdonalds-dev"]'
	$(MAKE) apply-target TARGET='kubernetes_ingress_v1.odoo["mcdonalds-dev"]'
	@echo "✓ McDonalds Dev deployment complete!"

# Quick deployment command
deploy-one: ## Interactive deployment of single environment
	@echo "Available environments:"
	@echo "  1. airbnb-dev"
	@echo "  2. airbnb-prod"
	@echo "  3. nike-dev"
	@echo "  4. nike-prod"
	@echo "  5. nike-qa"
	@echo "  6. mcdonalds-dev"
	@echo "  7. mcdonalds-prod"
	@echo "  8. mcdonalds-beta"
	@echo "  9. mcdonalds-qa"
	@echo ""
	@read -p "Enter environment name: " ENV; \
	if [ "$$ENV" = "airbnb-dev" ]; then $(MAKE) apply-airbnb-dev; \
	elif [ "$$ENV" = "airbnb-prod" ]; then $(MAKE) apply-airbnb-prod; \
	elif [ "$$ENV" = "nike-dev" ]; then $(MAKE) apply-nike-dev; \
	elif [ "$$ENV" = "nike-prod" ]; then $(MAKE) apply-nike-prod; \
	else echo "Environment $$ENV not yet implemented. Use apply-target directly."; fi

deploy-all: init validate ## Deploy all environments sequentially
	@echo "Deploying all environments sequentially with proper context switching..."
	@bash $(SCRIPTS_DIR)/deploy_sequential.sh

# Alias for common operations
setup: bootstrap ## Alias for bootstrap
redeploy: destroy apply ## Redeploy all infrastructure
check: validate ## Alias for validate
info: access-info ## Alias for access-info
