#!/bin/bash
# =============================================================================
# validate.sh - Validate all Odoo deployments
# =============================================================================
# This script validates HTTPS access to all deployed Odoo instances
# =============================================================================

# Don't use set -e as we want to continue even if some validations fail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Validating Odoo Deployments${NC}"
echo -e "${BLUE}========================================${NC}"

# Define clients and their environments
declare -A CLIENTS
CLIENTS["airbnb"]="dev prod"
CLIENTS["nike"]="dev qa prod"
CLIENTS["mcdonalds"]="dev qa beta prod"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to check if a cluster is running
check_cluster() {
    local client=$1
    local cluster_name="minikube-${client}"
    
    if minikube status -p "${cluster_name}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to validate a single endpoint
validate_endpoint() {
    local domain=$1
    local url="https://${domain}"
    
    ((TOTAL_TESTS++))
    
    echo -n "  Testing ${url}... "
    
    # Use curl with insecure flag for self-signed certs
    # -s: silent, -o: output to null, -w: write out http code
    # -k: insecure (accept self-signed), --connect-timeout: timeout
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" -k --connect-timeout 10 "${url}" 2>/dev/null || echo "000")
    
    if [ "$http_code" == "200" ] || [ "$http_code" == "303" ] || [ "$http_code" == "302" ]; then
        echo -e "${GREEN}OK (HTTP ${http_code})${NC}"
        ((PASSED_TESTS++))
        return 0
    elif [ "$http_code" == "000" ]; then
        echo -e "${RED}FAILED (Connection refused or timeout)${NC}"
        ((FAILED_TESTS++))
        return 1
    else
        echo -e "${YELLOW}WARNING (HTTP ${http_code})${NC}"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Function to validate a client
validate_client() {
    local client=$1
    local envs=$2
    
    echo -e "\n${YELLOW}Client: ${client}${NC}"
    
    if ! check_cluster "$client"; then
        echo -e "  ${RED}Cluster minikube-${client} is not running${NC}"
        for env in $envs; do
            ((TOTAL_TESTS++))
            ((FAILED_TESTS++))
        done
        return
    fi
    
    for env in $envs; do
        local domain="odoo.${env}.${client}.local"
        validate_endpoint "$domain"
    done
}

# Validate specific client or all
CLIENT_FILTER="${1:-all}"

if [ "$CLIENT_FILTER" == "all" ]; then
    for client in "${!CLIENTS[@]}"; do
        validate_client "$client" "${CLIENTS[$client]}"
    done
else
    if [ -n "${CLIENTS[$CLIENT_FILTER]}" ]; then
        validate_client "$CLIENT_FILTER" "${CLIENTS[$CLIENT_FILTER]}"
    else
        echo -e "${RED}Unknown client: ${CLIENT_FILTER}${NC}"
        echo "Available clients: ${!CLIENTS[*]}"
        exit 1
    fi
fi

# Summary
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Total tests: ${TOTAL_TESTS}"
echo -e "${GREEN}Passed: ${PASSED_TESTS}${NC}"
echo -e "${RED}Failed: ${FAILED_TESTS}${NC}"

if [ $FAILED_TESTS -eq 0 ] && [ $TOTAL_TESTS -gt 0 ]; then
    echo -e "\n${GREEN}All validations passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some validations failed.${NC}"
    exit 1
fi
