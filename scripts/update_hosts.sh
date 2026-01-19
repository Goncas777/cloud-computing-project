#!/bin/bash

# update_hosts.sh - Update /etc/hosts with domain mappings for Odoo applications
# This script extracts the IP addresses from Minikube clusters and updates /etc/hosts

set -e

HOSTS_FILE="/etc/hosts"
TERRAFORM_DIR="terraform"
BACKUP_SUFFIX=".backup.$(date +%s)"

echo "Updating /etc/hosts with domain mappings..."

# Extract domain and cluster information from Terraform
cd "$TERRAFORM_DIR"

# Get the domain mappings from Terraform output
DOMAINS=$(terraform output -json domain_map 2>/dev/null | jq -r 'to_entries[] | .value' 2>/dev/null || echo "")

if [ -z "$DOMAINS" ]; then
    echo "Warning: Could not extract domains from Terraform. Terraform may not be applied yet."
    cd ..
    exit 0
fi

cd ..

# Create backup
if [ -f "$HOSTS_FILE" ]; then
    cp "$HOSTS_FILE" "$HOSTS_FILE$BACKUP_SUFFIX"
    echo "Backed up $HOSTS_FILE to $HOSTS_FILE$BACKUP_SUFFIX"
fi

# Function to add or update host entry
add_host_entry() {
    local ip=$1
    local domain=$2
    
    if grep -q "^$ip[[:space:]].*$domain" "$HOSTS_FILE"; then
        echo "  Domain $domain already mapped to $ip"
    else
        # Remove any existing entries for this domain
        sed -i "/$domain/d" "$HOSTS_FILE" 2>/dev/null || true
        # Add new entry
        echo "$ip $domain" >> "$HOSTS_FILE"
        echo "  Added: $ip $domain"
    fi
}

# For Minikube clusters, we'll use localhost (127.0.0.1) as the IP
# This works in dev container environments
LOCAL_IP="127.0.0.1"

# Extract domains from Terraform and add them to /etc/hosts
echo "Adding domain entries to $HOSTS_FILE..."

cd "$TERRAFORM_DIR"
DOMAIN_JSON=$(terraform output -json domain_map 2>/dev/null || echo "{}")
cd ..

# Parse JSON and add domains
echo "$DOMAIN_JSON" | jq -r '.[] | select(. != null)' 2>/dev/null | while read -r domain; do
    add_host_entry "$LOCAL_IP" "$domain"
done

echo "✓ /etc/hosts updated successfully"

# Display current entries
echo ""
echo "Current Odoo domain entries in /etc/hosts:"
grep "odoo\." "$HOSTS_FILE" || echo "  (no entries found)"
