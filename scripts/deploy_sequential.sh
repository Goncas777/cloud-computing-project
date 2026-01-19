#!/bin/bash

# Deploy clusters sequentially with proper context switching
set -e

TERRAFORM_DIR="terraform"
ENVIRONMENTS=(
  "airbnb-dev"
  "airbnb-prod"
  "nike-dev"
  "nike-prod"
  "nike-qa"
  "mcdonalds-dev"
  "mcdonalds-prod"
  "mcdonalds-beta"
  "mcdonalds-qa"
)

echo "================================================================"
echo "Sequential Deployment of All Environments"
echo "================================================================"
echo ""

for env in "${ENVIRONMENTS[@]}"; do
  echo "📦 Deploying: $env"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # 1. Create/Refresh the cluster
  echo "   [1/4] Creating Minikube cluster..."
  cd "$TERRAFORM_DIR"
  terraform apply \
    -target="minikube_cluster.cluster[\"$env\"]" \
    -auto-approve \
    -no-color > /dev/null 2>&1 || true
  
  # 2. Update kubectl context
  echo "   [2/4] Configuring kubectl context..."
  minikube update-context -p "$env" 2>/dev/null || true
  kubectl config use-context "$env" 2>/dev/null || true
  
  # Wait for cluster to be ready
  echo "   [3/4] Waiting for cluster to be ready..."
  for i in {1..30}; do
    if kubectl cluster-info >/dev/null 2>&1; then
      echo "   ✓ Cluster ready"
      break
    fi
    if [ $i -eq 30 ]; then
      echo "   ✗ Cluster not ready after 30s, continuing anyway..."
    fi
    sleep 1
  done
  
  # 3. Apply remaining resources
  echo "   [4/4] Deploying Kubernetes resources..."
  terraform apply \
    -target="kubernetes_namespace.client_env[\"$env\"]" \
    -target="kubernetes_storage_class.postgres[\"$env\"]" \
    -target="kubernetes_secret.postgres[\"$env\"]" \
    -target="kubernetes_persistent_volume_claim.postgres[\"$env\"]" \
    -target="kubernetes_stateful_set.postgres[\"$env\"]" \
    -target="kubernetes_service.postgres[\"$env\"]" \
    -target="kubernetes_config_map.odoo[\"$env\"]" \
    -target="kubernetes_deployment.odoo[\"$env\"]" \
    -target="kubernetes_service.odoo[\"$env\"]" \
    -target="tls_private_key.odoo_key[\"$env\"]" \
    -target="tls_self_signed_cert.odoo_cert[\"$env\"]" \
    -target="kubernetes_secret.tls_cert[\"$env\"]" \
    -target="kubernetes_ingress_v1.odoo[\"$env\"]" \
    -auto-approve \
    -no-color > /dev/null 2>&1
  
  cd ..
  
  echo "   ✓ $env deployed successfully!"
  echo ""
done

echo "================================================================"
echo "✅ All environments deployed successfully!"
echo "================================================================"
echo ""
echo "To access an environment:"
echo "  kubectl config use-context <environment-name>"
echo "  kubectl get all --all-namespaces"
echo ""
echo "Available contexts:"
kubectl config get-contexts -o name | grep -E "(airbnb|nike|mcdonalds)" || echo "  (none)"
