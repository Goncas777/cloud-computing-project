#!/bin/bash

# show_kubeconfig.sh - Display kubeconfig location and usage information

set -e

TERRAFORM_DIR="terraform"

echo "Kubernetes Configuration"
echo "======================"
echo ""

cd "$TERRAFORM_DIR"

if ! terraform output -json minikube_clusters &>/dev/null; then
    echo "No clusters configured. Run 'make apply' first."
    exit 1
fi

CLUSTERS=$(terraform output -json minikube_clusters 2>/dev/null | jq -r '.[] | .name' 2>/dev/null || echo "")

cd ..

echo "Available Minikube Clusters:"
echo "---------------------------"

for cluster in $CLUSTERS; do
    echo ""
    echo "Cluster: $cluster"
    echo "  Profile: $cluster"
    
    if command -v minikube &> /dev/null; then
        KUBECONFIG_PATH=$(minikube profile list --output json 2>/dev/null | jq -r ".[] | select(.Name==\"$cluster\") | .Config" 2>/dev/null || echo "~/.kube/config")
        echo "  Kubeconfig: $KUBECONFIG_PATH"
        
        echo ""
        echo "  Usage:"
        echo "    kubectl --context=$cluster get nodes"
        echo "    kubectl --context=$cluster get pods -A"
        echo "    minikube -p $cluster ssh"
    else
        echo "  (minikube command not available)"
    fi
done

echo ""
echo "General Usage:"
echo "  Set context: kubectl config use-context <cluster-name>"
echo "  Get contexts: kubectl config get-contexts"
echo "  Get current context: kubectl config current-context"
