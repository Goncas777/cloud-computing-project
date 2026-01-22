#!/bin/bash
# =============================================================================
# apply-all.sh - Apply Terraform for all clients
# =============================================================================
# Applies infrastructure for all clients sequentially
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# List of clients
CLIENTS=("airbnb" "nike" "mcdonalds")

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Applying Terraform for ALL clients${NC}"
echo -e "${BLUE}========================================${NC}"

cd "$TERRAFORM_DIR"

# Ensure Terraform is initialized
if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}Initializing Terraform...${NC}"
    terraform init
fi

# Apply for each client
for client in "${CLIENTS[@]}"; do
    echo -e "\n${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Processing client: ${client}${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    # Select or create workspace
    terraform workspace select "$client" 2>/dev/null || terraform workspace new "$client"
    
    # Apply
    echo -e "${YELLOW}Applying Terraform for ${client}...${NC}"
    terraform apply -auto-approve
    
    echo -e "${GREEN}Completed: ${client}${NC}"
done

# Update /etc/hosts for all clients
echo -e "\n${YELLOW}Updating /etc/hosts...${NC}"
sudo "${SCRIPT_DIR}/update-hosts.sh" update

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}All clients deployed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"

# Show summary
echo -e "\n${YELLOW}Deployed environments:${NC}"
echo "- airbnb: dev, prod"
echo "- nike: dev, qa, prod"
echo "- mcdonalds: dev, qa, beta, prod"

echo -e "\n${YELLOW}Access URLs:${NC}"
for client in "${CLIENTS[@]}"; do
    terraform workspace select "$client" > /dev/null 2>&1
    terraform output -raw access_urls 2>/dev/null || true
    echo ""
done
