#!/bin/bash
# Valida se os endpoints estão a responder

echo "Validating Deployments..."
# Loop através dos domínios no /etc/hosts gerados por nós
grep "MANAGED_BY_TERRAFORM_ODOO" /etc/hosts | while read -r line ; do
    IP=$(echo $line | awk '{print $1}')
    DOMAIN=$(echo $line | awk '{print $2}')
    
    echo "Checking $DOMAIN ($IP)..."
    # -k ignora validação estrita de SSL (pois é self-signed)
    HTTP_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" https://$DOMAIN)
    
    if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "302" ]]; then
        echo "✅ $DOMAIN is UP (Status: $HTTP_CODE)"
    else
        echo "❌ $DOMAIN is DOWN (Status: $HTTP_CODE)"
    fi
done