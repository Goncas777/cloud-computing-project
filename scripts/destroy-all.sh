#!/bin/bash
# =============================================================================
# destroy-all.sh - Destroy Terraform resources for all clients
# =============================================================================
# Destroys infrastructure for all clients
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

echo -e "${RED}========================================${NC}"
echo -e "${RED}DESTROYING ALL Terraform resources${NC}"
echo -e "${RED}========================================${NC}"

echo -e "\n${RED}WARNING: This will destroy ALL resources for ALL clients!${NC}"
echo -e "${YELLOW}Type 'DESTROY ALL' to confirm:${NC}"
read -r response

if [ "$response" != "DESTROY ALL" ]; then
    echo -e "${YELLOW}Destruction cancelled.${NC}"
    exit 0
fi

cd "$TERRAFORM_DIR"

# Destroy for each client
for client in "${CLIENTS[@]}"; do
    echo -e "\n${RED}========================================${NC}"
    echo -e "${RED}Destroying client: ${client}${NC}"
    echo -e "${RED}========================================${NC}"
    
    # Check if workspace exists
    if terraform workspace list | grep -q "^\s*${client}$"; then
        terraform workspace select "$client"
        terraform destroy -auto-approve
        echo -e "${GREEN}Destroyed: ${client}${NC}"
    else
        echo -e "${YELLOW}Workspace '${client}' does not exist, skipping.${NC}"
    fi
done

# Clean up /etc/hosts
echo -e "\n${YELLOW}Cleaning /etc/hosts...${NC}"
sudo "${SCRIPT_DIR}/update-hosts.sh" remove

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}All resources destroyed!${NC}"
echo -e "${GREEN}========================================${NC}"
