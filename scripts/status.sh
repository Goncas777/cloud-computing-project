#!/bin/bash

# status.sh - Display status of all clusters and deployments

set -e

TERRAFORM_DIR="terraform"

echo "Infrastructure Status"
echo "===================="
echo ""

cd "$TERRAFORM_DIR"

# Check if Terraform has been applied
if ! terraform output -json namespaces &>/dev/null; then
    echo "Error: Terraform not applied. Run 'make apply' first."
    exit 1
fi

NAMESPACES=$(terraform output -json namespaces 2>/dev/null | jq -r '.[]' 2>/dev/null | sort | uniq)
CLUSTERS=$(terraform output -json minikube_clusters 2>/dev/null | jq -r '.[] | .name' 2>/dev/null || echo "")

cd ..

echo "Minikube Clusters:"
echo "---------------"
if command -v minikube &> /dev/null; then
    for cluster in $CLUSTERS; do
        echo -n "  $cluster: "
        if minikube status -p "$cluster" &>/dev/null; then
            minikube status -p "$cluster" | grep "kubelet:" | awk '{print $2}'
        else
            echo "Not found"
        fi
    done
else
    echo "  (minikube command not available)"
fi

echo ""
echo "Kubernetes Deployments:"
echo "---------------------"

while read -r namespace; do
    if [ -z "$namespace" ]; then
        continue
    fi
    
    echo "  Namespace: $namespace"
    kubectl get deployments -n "$namespace" --no-headers 2>/dev/null | awk '{print "    - " $1 ": " $2 "/" $3 " ready"}' || echo "    (unable to retrieve deployments)"
    
done <<< "$NAMESPACES"

echo ""
echo "Services:"
echo "--------"

while read -r namespace; do
    if [ -z "$namespace" ]; then
        continue
    fi
    
    SERVICES=$(kubectl get svc -n "$namespace" --no-headers 2>/dev/null | wc -l)
    if [ "$SERVICES" -gt 0 ]; then
        echo "  Namespace: $namespace ($SERVICES services)"
    fi
done <<< "$NAMESPACES"

echo ""
echo "Ingress Configuration:"
echo "---------------------"

while read -r namespace; do
    if [ -z "$namespace" ]; then
        continue
    fi
    
    INGRESSES=$(kubectl get ingress -n "$namespace" 2>/dev/null | tail -n +2)
    if [ -n "$INGRESSES" ]; then
        echo "  Namespace: $namespace"
        echo "$INGRESSES" | awk '{print "    - " $1 ": " $3}'
    fi
done <<< "$NAMESPACES"

echo ""
echo "✓ Status check complete"
