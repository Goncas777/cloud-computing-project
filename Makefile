# =============================================================================
# Makefile - Cloud Platform Engineering Automation
# =============================================================================
# Provides convenient targets for managing multi-client Kubernetes infrastructure
# =============================================================================

.PHONY: help init apply-all destroy-all validate hosts-update hosts-status \
        apply-airbnb apply-nike apply-mcdonalds \
        destroy-airbnb destroy-nike destroy-mcdonalds \
        validate-airbnb validate-nike validate-mcdonalds \
        plan-airbnb plan-nike plan-mcdonalds \
        status clean bootstrap

# Default target
help:
	@echo "=========================================="
	@echo "Cloud Platform Engineering - Makefile"
	@echo "=========================================="
	@echo ""
	@echo "Quick Start:"
	@echo "  make bootstrap         - Complete setup (init + deploy all + validate)"
	@echo ""
	@echo "Initialization:"
	@echo "  make init              - Initialize Terraform and create workspaces"
	@echo ""
	@echo "All Clients:"
	@echo "  make apply-all         - Deploy all clients"
	@echo "  make destroy-all       - Destroy all clients"
	@echo "  make validate          - Validate all deployments"
	@echo ""
	@echo "Per Client Operations:"
	@echo "  make apply-<client>    - Deploy specific client"
	@echo "  make destroy-<client>  - Destroy specific client"
	@echo "  make plan-<client>     - Plan for specific client"
	@echo "  make validate-<client> - Validate specific client"
	@echo ""
	@echo "Available clients: airbnb, nike, mcdonalds"
	@echo ""
	@echo "Utilities:"
	@echo "  make hosts-update      - Update /etc/hosts"
	@echo "  make hosts-status      - Show /etc/hosts entries"
	@echo "  make status            - Show cluster status"
	@echo "  make clean             - Clean Terraform files"
	@echo ""

# =============================================================================
# Bootstrap - Complete Setup from Scratch
# =============================================================================

bootstrap:
	@echo "=========================================="
	@echo "Bootstrapping Cloud Platform"
	@echo "=========================================="
	@echo ""
	@echo "Step 1/4: Initializing Terraform..."
	@$(MAKE) init
	@echo ""
	@echo "Step 2/4: Deploying all clients..."
	@$(MAKE) apply-all
	@echo ""
	@echo "Step 3/4: Updating /etc/hosts..."
	@$(MAKE) hosts-update
	@echo ""
	@echo "Step 4/4: Validating deployments..."
	@$(MAKE) validate
	@echo ""
	@echo "=========================================="
	@echo "Bootstrap Complete!"
	@echo "=========================================="

# =============================================================================
# Initialization
# =============================================================================

init:
	@echo "Initializing Terraform..."
	@cd terraform && terraform init
	@chmod +x scripts/*.sh
	@./scripts/init-workspaces.sh

# =============================================================================
# All Clients Operations
# =============================================================================

apply-all:
	@./scripts/apply-all.sh

destroy-all:
	@./scripts/destroy-all.sh

validate:
	@./scripts/validate.sh all

# =============================================================================
# AirBnB Operations
# =============================================================================

plan-airbnb:
	@cd terraform && terraform workspace select airbnb && terraform plan

apply-airbnb:
	@cd terraform && terraform workspace select airbnb 2>/dev/null || terraform workspace new airbnb
	@cd terraform && terraform apply -auto-approve
	@sudo ./scripts/update-hosts.sh update

destroy-airbnb:
	@cd terraform && terraform workspace select airbnb && terraform destroy -auto-approve
	@sudo ./scripts/update-hosts.sh update

validate-airbnb:
	@./scripts/validate.sh airbnb

# =============================================================================
# Nike Operations
# =============================================================================

plan-nike:
	@cd terraform && terraform workspace select nike && terraform plan

apply-nike:
	@cd terraform && terraform workspace select nike 2>/dev/null || terraform workspace new nike
	@cd terraform && terraform apply -auto-approve
	@sudo ./scripts/update-hosts.sh update

destroy-nike:
	@cd terraform && terraform workspace select nike && terraform destroy -auto-approve
	@sudo ./scripts/update-hosts.sh update

validate-nike:
	@./scripts/validate.sh nike

# =============================================================================
# McDonalds Operations
# =============================================================================

plan-mcdonalds:
	@cd terraform && terraform workspace select mcdonalds && terraform plan

apply-mcdonalds:
	@cd terraform && terraform workspace select mcdonalds 2>/dev/null || terraform workspace new mcdonalds
	@cd terraform && terraform apply -auto-approve
	@sudo ./scripts/update-hosts.sh update

destroy-mcdonalds:
	@cd terraform && terraform workspace select mcdonalds && terraform destroy -auto-approve
	@sudo ./scripts/update-hosts.sh update

validate-mcdonalds:
	@./scripts/validate.sh mcdonalds

# =============================================================================
# Utility Operations
# =============================================================================

hosts-update:
	@sudo ./scripts/update-hosts.sh update

hosts-status:
	@./scripts/update-hosts.sh status

status:
	@echo "=========================================="
	@echo "Minikube Clusters Status"
	@echo "=========================================="
	@minikube profile list 2>/dev/null || echo "No clusters found"
	@echo ""
	@echo "=========================================="
	@echo "Terraform Workspaces"
	@echo "=========================================="
	@cd terraform && terraform workspace list 2>/dev/null || echo "Terraform not initialized"

clean:
	@echo "Cleaning Terraform files..."
	@rm -rf terraform/.terraform
	@rm -rf terraform/.terraform.lock.hcl
	@rm -rf terraform/terraform.tfstate*
	@rm -rf terraform/tfplan
	@echo "Clean complete."

# =============================================================================
# Quick Test Commands (using curl)
# =============================================================================

test-airbnb-dev:
	@curl -k -s -o /dev/null -w "HTTP %{http_code}\n" https://odoo.dev.airbnb.local

test-airbnb-prod:
	@curl -k -s -o /dev/null -w "HTTP %{http_code}\n" https://odoo.prod.airbnb.local

test-nike-dev:
	@curl -k -s -o /dev/null -w "HTTP %{http_code}\n" https://odoo.dev.nike.local

test-nike-qa:
	@curl -k -s -o /dev/null -w "HTTP %{http_code}\n" https://odoo.qa.nike.local

test-nike-prod:
	@curl -k -s -o /dev/null -w "HTTP %{http_code}\n" https://odoo.prod.nike.local

test-mcdonalds-dev:
	@curl -k -s -o /dev/null -w "HTTP %{http_code}\n" https://odoo.dev.mcdonalds.local

test-mcdonalds-qa:
	@curl -k -s -o /dev/null -w "HTTP %{http_code}\n" https://odoo.qa.mcdonalds.local

test-mcdonalds-beta:
	@curl -k -s -o /dev/null -w "HTTP %{http_code}\n" https://odoo.beta.mcdonalds.local

test-mcdonalds-prod:
	@curl -k -s -o /dev/null -w "HTTP %{http_code}\n" https://odoo.prod.mcdonalds.local
