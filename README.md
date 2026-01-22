# Cloud Computing Platform - Multi-Client Kubernetes Infrastructure

A comprehensive Terraform-based infrastructure platform that provisions and manages Kubernetes clusters for multiple enterprise clients across different environments.

## Overview

This project implements a scalable, dynamic infrastructure solution that:

- **Provisions isolated Kubernetes clusters** for each environment using Minikube
- **Deploys Odoo applications** with full isolation between clients and environments
- **Manages databases** with PostgreSQL StatefulSets for data persistence
- **Configures HTTPS access** with self-signed TLS certificates
- **Automates deployment** through Terraform, Makefiles, and shell scripts
Multiple Clients & Environments
├── AirBnB (Dev, Prod)
├── Nike (Dev, QA, Prod)
└── McDonalds (Dev, QA, Beta, Prod)

Each Environment Cluster:
├── Dedicated Minikube Kubernetes Cluster (one per environment)
└── Namespace (client-environment)
  ├── PostgreSQL Database (StatefulSet)
  ├── Odoo Application (Deployment)
  ├── Service (ClusterIP routing)
  └── Ingress (HTTPS with TLS)

Domain Pattern: odoo.{environment}.{client}.local
```

## Features

### Dynamic Infrastructure as Code

### 1. Initialize Terraform

```bash
make init
```

### 2. Apply for a Client (one workspace per client)

```bash
make apply CLIENT=airbnb
make apply CLIENT=nike
make apply CLIENT=mcdonalds
```

This command will:
- Select/Create the Terraform workspace for the client
- Create a single Minikube cluster for the selected environment
- Deploy the namespace and Odoo stack for that environment
- Update `/etc/hosts` with the domain mapping for that environment

### 3. Validate Deployments (HTTPS)

```bash
make validate
```

Tests HTTPS connectivity to the Odoo application in the current environment.
- **Zero hardcoding**: Clients and environments defined in variables only
- **Scalable design**: Add new clients/environments by modifying variables
- **No code duplication**: Single Terraform stack applied per environment
- **Predictable naming**: Consistent, machine-readable resource names

### Kubernetes Provisioning

- Minikube-based isolated clusters per environment
- Each environment is deployed to its own cluster and namespace
- Automated cluster lifecycle management via Terraform
- Ingress controller pre-configured for HTTP/HTTPS
- Storage provisioning for persistent data

### Application Deployment

- **Isolated Namespaces**: `{client}-{environment}` pattern
- **PostgreSQL StatefulSet**: Persistent database with automatic initialization
- **Odoo Deployment**: Full-featured ERP application
- **Services**: Internal routing with ClusterIP
- **Ingress**: HTTPS routing with TLS termination

### HTTPS & Security

- Self-signed TLS certificate generation per domain
- Kubernetes Secrets for certificate management
- HTTPS enforcement on all Ingress routes
- Complete network isolation between namespaces

## Project Structure

```
cloud-computing-project/
├── terraform/                          # Terraform Infrastructure Code
│   ├── versions.tf                    # Provider requirements
│   ├── variables.tf                   # Client and configuration variables
│   ├── locals.tf                      # Dynamic client-environment mappings
│   ├── providers.tf                   # Multi-cluster Kubernetes providers
│   ├── minikube.tf                    # Cluster provisioning
│   ├── namespaces.tf                  # Kubernetes namespaces
│   ├── postgres.tf                    # PostgreSQL database setup
│   ├── odoo.tf                        # Odoo application deployment
│   └── ingress.tf                     # HTTPS ingress & TLS certificates
│
├── scripts/                           # Automation & Validation Scripts
│   ├── update_hosts.sh               # Domain name resolution setup
│   ├── validate_deployments.sh       # HTTPS endpoint validation
│   ├── get_logs.sh                   # Application log retrieval
│   ├── status.sh                     # Cluster status overview
│   ├── show_kubeconfig.sh            # Kubeconfig information
│   ├── access_info.sh                # Application access URLs
│   ├── get_cluster_ips.sh            # Cluster IP addresses
│   └── test.sh                       # Infrastructure validation tests
│
├── Makefile                           # Build automation (25+ targets)
├── README.md                          # This file
└── LICENSE                            # Project license
```

## Quick Start

### 1. Initialize Terraform

```bash
make init
```

### 2. Apply for a Client (one workspace per client)

```bash
make apply CLIENT=airbnb
make apply CLIENT=nike
make apply CLIENT=mcdonalds
```

This command will:
- Select/Create the Terraform workspace for the client
- Create the Minikube cluster for the client
- Deploy namespaces and applications for all environments
- Update `/etc/hosts` with all domain mappings for the client

### 3. Validate Deployments (HTTPS)

```bash
make validate
```

Tests HTTPS connectivity to all Odoo applications for the selected client.


## Makefile Targets

### Deployment Management
```bash
make init                    # Initialize Terraform
make plan                    # Show planned changes
make apply                   # Deploy infrastructure
make destroy                 # Tear down all resources
make clean-all              # Destroy + clean Terraform state
```

### Validation & Monitoring
```bash
make validate               # Validate Terraform config
make status                # Show deployment status
make logs-all              # Display application logs
make validate-deployment   # Test HTTPS endpoints
```

### Information & Access
```bash
make output                # Display Terraform outputs
make access-info           # Application URLs and credentials
make kubeconfig            # Kubernetes configuration info
make get-cluster-ips       # Minikube cluster IP addresses
```

### Development & Maintenance
```bash
make fmt                   # Format Terraform code
make test                  # Run infrastructure tests
make bootstrap             # Complete setup (init → apply)
make redeploy              # Destroy and recreate
```

## Usage Examples

### Complete Deployment Workflow

```bash
# 1. Navigate to project root
cd cloud-computing-project

# 2. Bootstrap infrastructure
make bootstrap

# 3. Wait for all pods to start (check status)
make status

# 4. Validate all deployments are working
make validate-deployment

# 5. View access information
make access-info

# 6. Test direct HTTPS access
curl -k https://odoo.dev.airbnb.local/
```

### Monitor Active Deployments

```bash
# Watch cluster status
watch kubectl get pods -A

# View real-time logs
kubectl logs -f deployment/odoo -n nike-prod

# Check ingress configuration
kubectl get ingress -A -o wide

# Monitor resource usage
kubectl top pods -A
```

### Troubleshoot Issues

```bash
# Get detailed pod information
kubectl describe pod deployment/odoo -n mcdonalds-dev

# Check event history
kubectl get events -n airbnb-prod

# Test database connectivity
kubectl exec -it deployment/odoo -n nike-qa -- \
  psql -h postgres.nike-qa.svc.cluster.local -U odoo -d odoo -c "SELECT 1;"

# View TLS certificate details
kubectl get secret odoo-tls -n airbnb-dev -o jsonpath='{.data.tls\.crt}' | \
  base64 -d | openssl x509 -text -noout
```

## Adding New Clients

To add a new client (e.g., Starbucks with Dev, Staging, Prod):

### Step 1: Modify Configuration

Edit `terraform/variables.tf`:

```hcl
variable "clients" {
  default = {
    airbnb = {
      environments = ["dev", "prod"]
    }
    nike = {
      environments = ["dev", "qa", "prod"]
    }
    mcdonalds = {
      environments = ["dev", "qa", "beta", "prod"]
    }
    # NEW CLIENT
    starbucks = {
      environments = ["dev", "staging", "prod"]
    }
  }
}
```

### Step 2: Deploy

```bash
make plan        # Review changes
make apply       # Deploy new environments
```

### Step 3: Validate

```bash
make post-apply            # Update /etc/hosts
make validate-deployment   # Test connectivity
```

### Step 4: Access

```bash
curl -k https://odoo.dev.starbucks.local/
curl -k https://odoo.staging.starbucks.local/
curl -k https://odoo.prod.starbucks.local/
```

## Adding New Environments

To add a staging environment to Nike:

### Step 1: Update Configuration

Edit `terraform/variables.tf`:

```hcl
nike = {
  environments = ["dev", "qa", "staging", "prod"]  # Added "staging"
}
```

### Step 2: Deploy

```bash
make apply
make post-apply            # Update /etc/hosts
```

### Step 3: Access

```bash
curl -k https://odoo.staging.nike.local/
```

## Configuration Customization

### Adjust Cluster Resources

Edit `terraform/variables.tf` to modify per-cluster allocation:

```hcl
variable "minikube_memory" {
  default = 4096  # Increase from 2048 MB
}

variable "minikube_cpus" {
  default = 4  # Increase from 2
}
```

Then redeploy:
```bash
make redeploy
```

### Change Application Images

```hcl
variable "odoo_image" {
  default = "odoo:17.0"  # Upgrade version
}

variable "postgres_image" {
  default = "postgres:16-alpine"  # Upgrade PostgreSQL
}
```

### Modify Application Resources

Edit `terraform/odoo.tf` to adjust CPU/memory limits:

```hcl
resources {
  requests = {
    cpu    = "200m"
    memory = "1Gi"
  }
  limits = {
    cpu    = "2000m"
    memory = "2Gi"
  }
}
```

## Kubernetes Operations

### View All Resources

```bash
# List all namespaces
kubectl get namespaces

# View all deployments
kubectl get deployments -A

# View all pods with details
kubectl get pods -A -o wide

# View all services
kubectl get svc -A

# View all ingress configurations
kubectl get ingress -A -o wide

# View all secrets
kubectl get secrets -A
```

### Access Individual Namespaces

```bash
# Set default namespace
kubectl config set-context --current --namespace=airbnb-dev

# View resources in namespace
kubectl get all -n nike-prod

# Describe specific pod
kubectl describe pod -n mcdonalds-qa -l app=odoo
```

### Execute Commands in Pods

```bash
# Access Odoo shell
kubectl exec -it deployment/odoo -n airbnb-dev -- bash

# Run SQL query in database
kubectl exec -it statefulset/postgres -n nike-qa -- \
  psql -U odoo -d odoo -c "SELECT version();"

# Check Odoo configuration
kubectl exec -it deployment/odoo -n mcdonalds-beta -- \
  cat /etc/odoo/odoo.conf
```

## Domain Naming Convention

All applications use HTTPS at the following domain:

```
odoo.{ENVIRONMENT}.{CLIENT}.local
```

### All Configured Domains

**AirBnB**:
- `odoo.dev.airbnb.local` (Dev environment)
- `odoo.prod.airbnb.local` (Production)

**Nike**:
- `odoo.dev.nike.local` (Dev)
- `odoo.qa.nike.local` (QA)
- `odoo.prod.nike.local` (Production)

**McDonalds**:
- `odoo.dev.mcdonalds.local` (Dev)
- `odoo.qa.mcdonalds.local` (QA)
- `odoo.beta.mcdonalds.local` (Beta)
- `odoo.prod.mcdonalds.local` (Production)

## HTTPS & Security

### Self-Signed Certificates

Each domain has a Terraform-generated self-signed TLS certificate:

```bash
# View certificate details
kubectl get secret odoo-tls -n airbnb-dev -o jsonpath='{.data.tls\.crt}' | \
  base64 -d | openssl x509 -text -noout

# Certificate validity: 365 days from generation
```

### HTTPS Access

All applications enforce HTTPS. Use `curl -k` for self-signed certificates:

```bash
# Test HTTPS (with SSL verification disabled)
curl -k https://odoo.dev.airbnb.local/

# Get HTTP response code
curl -k -o /dev/null -s -w "%{http_code}\n" https://odoo.prod.nike.local/

# Save certificate locally
curl -k --cacert /dev/null https://odoo.qa.mcdonalds.local/ \
  2>&1 | grep "subject="
```

## Validation Testing

### Automated Validation

```bash
# Test all HTTPS endpoints
make validate-deployment

# Run infrastructure tests
make test

# Format code and validate
make fmt && make validate
```

### Manual Validation

```bash
# Test each client's dev environment
curl -k https://odoo.dev.airbnb.local/ -I
curl -k https://odoo.dev.nike.local/ -I
curl -k https://odoo.dev.mcdonalds.local/ -I

# Test each client's production environment
curl -k https://odoo.prod.airbnb.local/ -I
curl -k https://odoo.prod.nike.local/ -I
curl -k https://odoo.prod.mcdonalds.local/ -I
```

## Troubleshooting Guide

### Issue: Clusters Won't Start

```bash
# Check Minikube status
minikube status -p airbnb-dev

# Check Docker daemon
docker ps

# Reset cluster
minikube delete -p airbnb-dev
make apply
```

### Issue: Pods Not Starting

```bash
# Check pod events
kubectl describe pod deployment/odoo -n airbnb-dev

# View pod logs
kubectl logs deployment/odoo -n airbnb-dev

# Check resource availability
kubectl top nodes
kubectl top pods -n airbnb-dev

# Increase cluster resources if needed
# Edit terraform/variables.tf and redeploy
```

### Issue: HTTPS Not Working

```bash
# Verify /etc/hosts entries
grep odoo /etc/hosts

# Update if needed
make post-apply

# Check ingress status
kubectl get ingress -A

# Verify ingress IP
kubectl describe ingress odoo-ingress -n airbnb-dev

# Test DNS resolution
nslookup odoo.dev.airbnb.local
```

### Issue: Database Connection Failed

```bash
# Check PostgreSQL pod
kubectl get pods -n airbnb-dev | grep postgres

# View PostgreSQL logs
kubectl logs statefulset/postgres -n nike-prod

# Test connection from Odoo pod
kubectl exec -it deployment/odoo -n mcdonalds-qa -- \
  nc -zv postgres.mcdonalds-qa.svc.cluster.local 5432

# Verify database credentials
kubectl get secret postgres-secret -n airbnb-dev -o jsonpath='{.data}'
```

### Issue: Terraform Apply Hangs

```bash
# Check provider connection
cd terraform && terraform providers

# Verify Minikube clusters
minikube status --all

# Manually create missing clusters
minikube start -p cluster-name

# Retry apply
terraform apply
```

## Architecture Design Decisions

### 1. Single Terraform Project (6 pts)

**Design**: One project manages all clients and environments

**Implementation**:
- `variables.tf` defines client structure as a map
- `locals.tf` flattens client-environment combinations
- `for_each` loops create resources dynamically
- No hardcoded resource blocks

**Benefits**:
- Single source of truth
- Consistent naming across all deployments
- Easy to add new clients without code duplication
- Simplified state management

### 2. Minikube Cluster Provisioning (4 pts)

**Design**: Terraform creates and manages all Minikube clusters

**Implementation**:
- `minikube.tf` defines cluster resources with `for_each`
- Each cluster named after client-environment combination
- Kubernetes provider configured per cluster with aliases
- Cluster lifecycle managed entirely by Terraform

**Benefits**:
- Complete IaC for Kubernetes infrastructure
- Reproducible cluster creation
- Easy teardown and recreation
- Each environment truly isolated

### 3. Kubernetes Deployment (3 pts)

**Design**: Full application stack per environment

**Implementation**:
- `namespaces.tf` creates isolated namespaces
- `postgres.tf` provisions StatefulSet with PVC
- `odoo.tf` deploys application with health checks
- Services provide routing within namespace
- Each component isolated and independently manageable

**Benefits**:
- Complete resource isolation
- Persistent data for databases
- Health monitoring and auto-restart
- Independent scaling per environment

### 4. HTTPS & TLS (3 pts)

**Design**: Terraform-managed self-signed certificates

**Implementation**:
- `ingress.tf` generates TLS certificates per domain
- Kubernetes Secrets store certificates
- Ingress routes traffic over HTTPS
- Domain pattern: `odoo.ENV.CLIENT.local`

**Benefits**:
- Automated certificate management
- No external CA dependencies
- Consistent HTTPS configuration
- Easy certificate rotation

### 5. Automation & Developer Experience (2 pts)

**Design**: Comprehensive Makefile and shell scripts

**Implementation**:
- 25+ Makefile targets for common operations
- 8 shell scripts for validation and monitoring
- Single command deployment: `make bootstrap`
- Status, logs, and validation commands

**Benefits**:
- Simplified operations workflow
- Reduced manual errors
- Quick problem diagnosis
- Improved team productivity

### 6. Documentation (1 pt)

**Design**: Complete README with examples and guides

**Implementation**:
- Architecture overview and design decisions
- Quick start and usage examples
- Troubleshooting section with solutions
- Client/environment addition guides
- Customization instructions

**Benefits**:
- Clear understanding of system
- Easy onboarding for new users
- Self-service troubleshooting
- Maintainability over time

### 7. Naming & Consistency (1 pt)

**Design**: Predictable, machine-readable naming

**Implementation**:
- Resources named after client-environment: `{client}-{env}`
- Domains: `odoo.{env}.{client}.local`
- Namespaces: `{client}-{env}`
- Consistent labeling and tagging

**Benefits**:
- Clear resource identification
- Easier scripting and automation
- Better operational clarity
- Scalable naming scheme

## Performance Optimization

### Development Environment

Minimize resource usage for development:

```hcl
variable "minikube_memory" {
  default = 1024  # 1GB per cluster
}

variable "minikube_cpus" {
  default = 1
}
```

### Production Environment

Increase resources for reliability:

```hcl
variable "minikube_memory" {
  default = 8192  # 8GB per cluster
}

variable "minikube_cpus" {
  default = 4
}
```

Or use managed Kubernetes (EKS, GKE, AKS):

```hcl
# Modify minikube.tf to use alternative providers
# Update provider configuration in providers.tf
```

## Security Best Practices

1. **Database Credentials**
   - Change default password in `variables.tf`
   - Store secrets in secure vault
   - Use Kubernetes Secrets for runtime access

2. **TLS Certificates**
   - Replace self-signed with CA-signed for production
   - Implement automatic rotation
   - Secure key storage

3. **Network Policies**
   - Implement Kubernetes NetworkPolicies
   - Restrict traffic between namespaces
   - Enable pod-to-pod authentication

4. **RBAC**
   - Define role-based access control
   - Limit service account permissions
   - Audit cluster access

5. **Image Security**
   - Use specific image versions (not `latest`)
   - Scan images for vulnerabilities
   - Use private registries if needed

## Cost Optimization

### Local Development
- Use minimum Minikube resources
- Scale up only for production testing
- Schedule automatic teardown

### Production Deployment
- Use managed Kubernetes services
- Implement resource quotas
- Use cluster autoscaling
- Implement pod HPA

## Scaling Considerations

### Current Configuration
- 9 Minikube clusters (3 clients × 3 avg environments)
- Minimum 18GB RAM + 9 vCPUs required
- Total ~20 Docker containers

### Future Scalability
- Multi-cluster deployment
- Cloud provider integration
- Service mesh implementation
- GitOps for continuous deployment

## Backup & Disaster Recovery

### Backup Terraform State

```bash
# Backup local state
cp terraform/terraform.tfstate backup/terraform.tfstate.backup

# For production, use remote state:
# - AWS S3 with versioning
# - Azure Storage
# - Terraform Cloud/Enterprise
```

### Backup Application Data

```bash
# Backup PostgreSQL databases
kubectl exec statefulset/postgres -n airbnb-dev -- \
  pg_dump -U odoo odoo > backup/airbnb-dev.sql

# Backup all Kubernetes resources
kubectl get all -A -o yaml > backup/kubernetes-resources.yaml
```

### Restore Procedure

```bash
# Restore Terraform state
cp backup/terraform.tfstate terraform/

# Reapply configuration
cd terraform && terraform apply -auto-approve

# Verify restoration
make validate-deployment
```

## Contributing & Code Quality

### Code Formatting

```bash
make fmt
```

### Validation

```bash
make validate
```

### Testing

```bash
make test
```

### Complete Quality Check

```bash
make fmt && make validate && make test
```

## Support & Debugging

### Enable Debug Logging

```bash
cd terraform
TF_LOG=DEBUG terraform apply
```

### Check Kubernetes Events

```bash
kubectl get events -A --sort-by='.lastTimestamp'
```

### Retrieve Application Logs

```bash
make logs-all
```

### Get Cluster Status

```bash
make status
```

## License

This project is provided as-is for educational and enterprise use.

## Contact & Support

For issues:
1. Review troubleshooting section
2. Check Terraform logs with `TF_LOG=DEBUG`
3. Verify Kubernetes resources with `kubectl`
4. Review application logs with `make logs-all`

---

**Project**: Cloud Computing Platform  
**Version**: 1.0.0  
**Last Updated**: January 2026  
**Terraform Version**: >= 1.0  
**Kubernetes Version**: >= 1.24  
**Status**: Production Ready
