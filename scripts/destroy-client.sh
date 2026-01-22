#!/bin/bash
# =============================================================================
# destroy-client.sh - Destroy Terraform resources for a specific client
# =============================================================================
# Usage: ./destroy-client.sh <client_name>
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

echo -e "${RED}========================================${NC}"
echo -e "${RED}Destroying Terraform resources for: ${CLIENT}${NC}"
echo -e "${RED}========================================${NC}"

cd "$TERRAFORM_DIR"

# Check if workspace exists
if ! terraform workspace list | grep -q "^\s*${CLIENT}$"; then
    echo -e "${YELLOW}Workspace '${CLIENT}' does not exist.${NC}"
    exit 0
fi

# Select the workspace
echo -e "${YELLOW}Selecting workspace: ${CLIENT}${NC}"
terraform workspace select "$CLIENT"

# Confirm destruction
echo -e "\n${RED}WARNING: This will destroy all resources for ${CLIENT}!${NC}"
echo -e "${YELLOW}Type '${CLIENT}' to confirm destruction:${NC}"
read -r response

if [ "$response" == "$CLIENT" ]; then
    echo -e "\n${YELLOW}Destroying Terraform resources...${NC}"
    terraform destroy -auto-approve
    
    echo -e "\n${GREEN}Resources destroyed for ${CLIENT}!${NC}"
    
    # Update /etc/hosts
    echo -e "\n${YELLOW}Updating /etc/hosts...${NC}"
    sudo "${SCRIPT_DIR}/update-hosts.sh" update
else
    echo -e "${YELLOW}Destruction cancelled.${NC}"
    exit 0
fi
