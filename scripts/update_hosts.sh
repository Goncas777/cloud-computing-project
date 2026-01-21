#!/bin/bash
echo "Updating /etc/hosts (requires sudo)..."
sudo sed -i '/# MANAGED_BY_TERRAFORM_ODOO/d' /etc/hosts

CLIENT=$(cd terraform && terraform output -raw current_client 2>/dev/null || echo "")
DOMAIN_JSON=$(cd terraform && terraform output -json domain_map 2>/dev/null || echo "{}")

if [ -z "$CLIENT" ] || [ "$CLIENT" = "default" ]; then
    echo "No active client workspace found. Run: terraform workspace select <client>"
    exit 1
fi

IP=$(minikube ip -p "$CLIENT" 2>/dev/null | head -n 1 | grep -E '^[0-9]+(\.[0-9]+){3}$' || true)
if [ -z "$IP" ]; then
    echo "Cluster $CLIENT not running. Start it with minikube start -p $CLIENT --force"
    exit 1
fi

echo "$DOMAIN_JSON" | jq -r 'to_entries[] | "\(.value)"' | while read -r DOMAIN; do
    if [ -n "$DOMAIN" ]; then
        echo "$IP $DOMAIN # MANAGED_BY_TERRAFORM_ODOO" | sudo tee -a /etc/hosts > /dev/null
        echo "Mapped $DOMAIN to $IP"
    fi
done