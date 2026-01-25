#!/bin/bash
# =============================================================================
# update-hosts.sh - Update /etc/hosts with Minikube cluster IPs
# =============================================================================
# This script updates /etc/hosts with the domain entries for all clients
# Must be run with sudo privileges
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Marker for managed entries
MARKER="# MANAGED_BY_TERRAFORM_ODOO"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Updating /etc/hosts for Odoo domains${NC}"
echo -e "${YELLOW}========================================${NC}"

# Define clients and their environments
declare -A CLIENTS
CLIENTS["airbnb"]="dev prod"
CLIENTS["nike"]="dev qa prod"
CLIENTS["mcdonalds"]="dev qa beta prod"

# Function to get Minikube IP for a client cluster
get_minikube_ip() {
    local client=$1
    local cluster_name="minikube-${client}"
    
    # Try to get the IP from minikube
    local ip=$(minikube ip -p "${cluster_name}" 2>/dev/null || echo "")
    
    if [ -z "$ip" ]; then
        echo ""
    else
        echo "$ip"
    fi
}

# Function to remove old entries
remove_old_entries() {
    echo -e "${YELLOW}Removing old Odoo domain entries from /etc/hosts...${NC}"
    
    # Remove lines with our marker
    grep -v "${MARKER}" /etc/hosts > /tmp/hosts.new 2>/dev/null || true
    cat /tmp/hosts.new | sudo tee /etc/hosts > /dev/null
    rm -f /tmp/hosts.new
    
    echo -e "${GREEN}Old entries removed.${NC}"
}

# Function to add new entries
add_hosts_entries() {
    echo -e "${YELLOW}Adding new /etc/hosts entries...${NC}"
    
    local entries_added=0
    
    for client in "${!CLIENTS[@]}"; do
        local ip=$(get_minikube_ip "$client")
        
        if [ -n "$ip" ]; then
            local envs=${CLIENTS[$client]}
            
            for env in $envs; do
                local domain="odoo.${env}.${client}.local"
                echo -e "${GREEN}Adding: ${ip} ${domain}${NC}"
                echo "${ip} ${domain} ${MARKER}" | sudo tee -a /etc/hosts > /dev/null
                entries_added=$((entries_added + 1))
            done
        else
            echo -e "${YELLOW}Warning: Cluster minikube-${client} not running, skipping...${NC}"
        fi
    done
    
    if [ $entries_added -gt 0 ]; then
        echo -e "${GREEN}Added ${entries_added} entries to /etc/hosts${NC}"
    else
        echo -e "${RED}No entries added. Make sure clusters are running.${NC}"
    fi
}

# Function to add entries for a single client
add_client_entries() {
    local client=$1
    
    if [ -z "${CLIENTS[$client]}" ]; then
        echo -e "${RED}Unknown client: ${client}${NC}"
        return 1
    fi
    
    local ip=$(get_minikube_ip "$client")
    
    if [ -z "$ip" ]; then
        echo -e "${RED}Cluster minikube-${client} not running${NC}"
        return 1
    fi
    
    # Remove old entries for this client
    grep -v "odoo\..*\.${client}\.local" /etc/hosts > /tmp/hosts.new 2>/dev/null || cat /etc/hosts > /tmp/hosts.new
    cat /tmp/hosts.new | sudo tee /etc/hosts > /dev/null
    rm -f /tmp/hosts.new
    
    local envs=${CLIENTS[$client]}
    for env in $envs; do
        local domain="odoo.${env}.${client}.local"
        echo -e "${GREEN}Adding: ${ip} ${domain}${NC}"
        echo "${ip} ${domain} ${MARKER}" | sudo tee -a /etc/hosts > /dev/null
    done
}

# Function to show current status
show_status() {
    echo -e "\n${YELLOW}Current /etc/hosts Odoo entries:${NC}"
    grep -E 'odoo\.[a-z]*\.(airbnb|nike|mcdonalds)\.local' /etc/hosts 2>/dev/null || echo "No entries found"
}

# Main execution
case "${1:-update}" in
    update)
        remove_old_entries
        add_hosts_entries
        show_status
        ;;
    client)
        if [ -z "$2" ]; then
            echo -e "${RED}Usage: $0 client <client_name>${NC}"
            exit 1
        fi
        add_client_entries "$2"
        show_status
        ;;
    remove)
        remove_old_entries
        show_status
        ;;
    status)
        show_status
        ;;
    *)
        echo "Usage: $0 {update|client <name>|remove|status}"
        echo ""
        echo "Commands:"
        echo "  update           - Update hosts for all running clusters"
        echo "  client <name>    - Update hosts for a specific client"
        echo "  remove           - Remove all managed entries"
        echo "  status           - Show current managed entries"
        exit 1
        ;;
esac

echo -e "\n${GREEN}Done!${NC}"
