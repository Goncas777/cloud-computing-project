#!/bin/bash

# validate_deployments.sh - Validate Odoo deployments using curl
# This script performs HTTPS requests to each Odoo application and validates connectivity

set -e

TERRAFORM_DIR="terraform"
VALIDATION_RESULTS="/tmp/validation_results.txt"

echo "Validating Odoo deployments..."
echo "==============================="
echo ""

# Clear previous results
> "$VALIDATION_RESULTS"

# Extract domains and cluster info from Terraform
cd "$TERRAFORM_DIR"

if ! terraform output -json client_environments &>/dev/null; then
    echo "Error: Terraform not initialized. Run 'make apply' first."
    exit 1
fi

DOMAIN_JSON=$(terraform output -json domain_map 2>/dev/null || echo "{}")
CLIENT_ENVS=$(terraform output -json client_environments 2>/dev/null || echo "{}")

cd ..

# Test each domain
echo "Testing HTTPS connectivity to each Odoo application..."
echo "$DOMAIN_JSON" | jq -r 'to_entries[] | "\(.key) \(.value)"' 2>/dev/null | while read -r key domain; do
    if [ -z "$domain" ]; then
        continue
    fi
    
    echo -n "Testing $domain... "
    
    # Try connecting with curl (ignore SSL verification for self-signed certs)
    if curl -s -k -m 5 "https://$domain/" > /dev/null 2>&1; then
        echo "✓ SUCCESS"
        echo "✓ $domain - OK" >> "$VALIDATION_RESULTS"
    else
        echo "✗ FAILED (timeout or connection refused)"
        echo "✗ $domain - FAILED" >> "$VALIDATION_RESULTS"
    fi
done

echo ""
echo "Validation Summary:"
echo "==================="
cat "$VALIDATION_RESULTS"

# Count successes and failures
SUCCESSES=$(grep -c "✓" "$VALIDATION_RESULTS" || echo 0)
FAILURES=$(grep -c "✗" "$VALIDATION_RESULTS" || echo 0)

echo ""
echo "Results: $SUCCESSES successful, $FAILURES failed"

if [ "$FAILURES" -eq 0 ] && [ "$SUCCESSES" -gt 0 ]; then
    echo "✓ All deployments validated successfully!"
    exit 0
else
    echo "✗ Some deployments failed validation"
    echo ""
    echo "Troubleshooting tips:"
    echo "  1. Ensure Minikube clusters are running: minikube status --all"
    echo "  2. Check /etc/hosts entries: grep odoo /etc/hosts"
    echo "  3. Check ingress status: kubectl get ingress -A"
    echo "  4. Check pod status: kubectl get pods -A"
    exit 1
fi
