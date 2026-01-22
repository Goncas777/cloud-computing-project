#!/bin/bash
# =============================================================================
# init-workspaces.sh - Initialize Terraform workspaces for all clients
# =============================================================================
# Creates Terraform workspaces for each client
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# List of clients
CLIENTS=("airbnb" "nike" "mcdonalds")

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Initializing Terraform Workspaces${NC}"
echo -e "${YELLOW}========================================${NC}"

cd "$TERRAFORM_DIR"

# Initialize Terraform if not already done
if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}Running terraform init...${NC}"
    terraform init
fi

# Create workspaces for each client
for client in "${CLIENTS[@]}"; do
    echo -e "\n${YELLOW}Creating workspace: ${client}${NC}"
    
    # Check if workspace already exists
    if terraform workspace list | grep -q "^\s*${client}$"; then
        echo -e "${GREEN}Workspace '${client}' already exists.${NC}"
    else
        terraform workspace new "$client"
        echo -e "${GREEN}Workspace '${client}' created.${NC}"
    fi
done

# List all workspaces
echo -e "\n${YELLOW}Available Terraform workspaces:${NC}"
terraform workspace list

echo -e "\n${GREEN}Workspace initialization complete!${NC}"
echo -e "${YELLOW}Use 'terraform workspace select <client>' to switch workspaces.${NC}"
