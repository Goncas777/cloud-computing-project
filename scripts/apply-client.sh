#!/bin/bash
# =============================================================================
# apply-client.sh - Apply Terraform for a specific client
# =============================================================================
# Usage: ./apply-client.sh <client_name>
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validate arguments
if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <client_name>${NC}"
    echo "Available clients: airbnb, nike, mcdonalds"
    exit 1
fi

CLIENT=$1

# Validate client name
VALID_CLIENTS=("airbnb" "nike" "mcdonalds")
if [[ ! " ${VALID_CLIENTS[*]} " =~ " ${CLIENT} " ]]; then
    echo -e "${RED}Invalid client: ${CLIENT}${NC}"
    echo "Available clients: ${VALID_CLIENTS[*]}"
    exit 1
fi

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Applying Terraform for client: ${CLIENT}${NC}"
echo -e "${YELLOW}========================================${NC}"

cd "$TERRAFORM_DIR"

# Ensure Terraform is initialized
if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}Initializing Terraform...${NC}"
    terraform init
fi

# Select the workspace
echo -e "${YELLOW}Selecting workspace: ${CLIENT}${NC}"
terraform workspace select "$CLIENT" 2>/dev/null || terraform workspace new "$CLIENT"

# Plan first
echo -e "\n${YELLOW}Running terraform plan...${NC}"
terraform plan -out=tfplan

# Ask for confirmation
echo -e "\n${YELLOW}Do you want to apply this plan? (yes/no)${NC}"
read -r response

if [ "$response" == "yes" ]; then
    echo -e "\n${YELLOW}Applying Terraform configuration...${NC}"
    terraform apply tfplan
    rm -f tfplan
    
    echo -e "\n${GREEN}Terraform apply complete for ${CLIENT}!${NC}"
    
    # Update /etc/hosts
    echo -e "\n${YELLOW}Updating /etc/hosts...${NC}"
    sudo "${SCRIPT_DIR}/update-hosts.sh" update
    
    # Show access information
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Deployment Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    terraform output
else
    echo -e "${YELLOW}Apply cancelled.${NC}"
    rm -f tfplan
    exit 0
fi
