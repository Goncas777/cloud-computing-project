#!/bin/bash

# access_info.sh - Display access information for all Odoo applications

set -e

TERRAFORM_DIR="terraform"

echo "Application Access Information"
echo "=============================="
echo ""

cd "$TERRAFORM_DIR"

if ! terraform output -json domain_map &>/dev/null; then
    echo "Error: No applications configured. Run 'make apply' first."
    exit 1
fi

DOMAIN_JSON=$(terraform output -json domain_map 2>/dev/null || echo "{}")

cd ..

echo "HTTPS Access Endpoints:"
echo "---------------------"
echo ""

echo "$DOMAIN_JSON" | jq -r 'to_entries[] | "\(.key) \(.value)"' 2>/dev/null | while read -r key domain; do
    if [ -z "$domain" ]; then
        continue
    fi
    
    # Parse client and environment from key
    CLIENT=$(echo "$key" | cut -d'-' -f1)
    ENV=$(echo "$key" | cut -d'-' -f2)
    
    echo "Client: $CLIENT | Environment: $ENV"
    echo "  URL: https://$domain"
    echo "  Curl command: curl -k https://$domain/"
    echo "  Credentials: Admin / admin (default)"
    echo ""
done

echo "Important Notes:"
echo "---------------"
echo "1. All applications use self-signed HTTPS certificates"
echo "2. Use 'curl -k' flag to ignore SSL verification for testing"
echo "3. Ensure /etc/hosts is updated with domain mappings:"
echo "   grep odoo /etc/hosts"
echo ""
echo "4. Each client and environment is isolated in its own:"
echo "   - Kubernetes cluster (via Minikube)"
echo "   - Namespace (${CLIENT}-${ENV})"
echo "   - PostgreSQL database"
echo "   - Odoo instance"
