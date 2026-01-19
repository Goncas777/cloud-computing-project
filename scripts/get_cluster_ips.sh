#!/bin/bash

# get_cluster_ips.sh - Get IP addresses of all Minikube clusters

set -e

TERRAFORM_DIR="terraform"

echo "Minikube Cluster IP Addresses"
echo "============================"
echo ""

cd "$TERRAFORM_DIR"

if ! terraform output -json minikube_clusters &>/dev/null; then
    echo "No clusters configured. Run 'make apply' first."
    exit 1
fi

CLUSTERS=$(terraform output -json minikube_clusters 2>/dev/null | jq -r '.[] | .name' 2>/dev/null || echo "")

cd ..

if [ -z "$CLUSTERS" ]; then
    echo "No clusters found"
    exit 1
fi

for cluster in $CLUSTERS; do
    if command -v minikube &> /dev/null; then
        echo -n "$cluster: "
        minikube ip -p "$cluster" 2>/dev/null || echo "Not running"
    fi
done

echo ""
echo "Note: In DevContainer environments, use 127.0.0.1 for local testing"
