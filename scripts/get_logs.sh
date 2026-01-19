#!/bin/bash

# get_logs.sh - Display logs from all Odoo deployments

set -e

TERRAFORM_DIR="terraform"

echo "Fetching Odoo application logs..."
echo "=================================="
echo ""

cd "$TERRAFORM_DIR"

# Get all namespaces
NAMESPACES=$(terraform output -json namespaces 2>/dev/null | jq -r '.[]' 2>/dev/null | sort | uniq)

cd ..

if [ -z "$NAMESPACES" ]; then
    echo "No namespaces found. Run 'make apply' first."
    exit 1
fi

# For each namespace, get logs from the Odoo deployment
while read -r namespace; do
    if [ -z "$namespace" ]; then
        continue
    fi
    
    echo "=== Logs from namespace: $namespace ==="
    echo ""
    
    # Get all pods in the namespace
    PODS=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")
    
    for pod in $PODS; do
        if [[ "$pod" == "odoo"* ]]; then
            echo "Pod: $pod"
            kubectl logs -n "$namespace" "$pod" --tail=20 2>/dev/null || echo "  (no logs available)"
            echo ""
        fi
    done
done <<< "$NAMESPACES"

echo "✓ Log retrieval complete"
