# Deployment Checklist

## Pre-Deployment Requirements

### System Requirements
- [ ] Terraform >= 1.0 installed
- [ ] Minikube latest version installed
- [ ] kubectl installed
- [ ] Docker daemon running
- [ ] jq installed (for JSON parsing)
- [ ] 18+ GB RAM available
- [ ] 18+ vCPUs available
- [ ] 50+ GB free disk space

### Verification
```bash
# Verify all tools
terraform version
minikube version
kubectl version --client
docker ps
jq --version
```

## Pre-Deployment Steps

### 1. Environment Setup
- [ ] Clone/download project
- [ ] Navigate to project root: `cd cloud-computing-project`
- [ ] Verify file structure: `ls -la terraform/ scripts/ Makefile`
- [ ] Ensure all scripts are executable: `ls -la scripts/*.sh`

### 2. Configuration Review
- [ ] Review `terraform/variables.tf` for client definitions
- [ ] Verify default resources (memory, CPU)
- [ ] Check database credentials (consider changing for production)
- [ ] Review Odoo image versions

### 3. Infrastructure Planning
- [ ] Confirm 9 clusters needed (3 clients × 3-4 environments)
- [ ] Verify network connectivity
- [ ] Check if /etc/hosts is writable (for domain mapping)
- [ ] Ensure Minikube can start clusters

## Deployment Process

### Step 1: Initialize Terraform
```bash
make init
```
- [ ] Command completes without errors
- [ ] `.terraform` directory created
- [ ] `terraform.lock.hcl` generated

### Step 2: Validate Configuration
```bash
make validate
```
- [ ] All resources validate successfully
- [ ] No syntax errors
- [ ] Provider requirements met

### Step 3: Plan Deployment
```bash
make plan
```
- [ ] Review proposed changes
- [ ] Verify 9 clusters will be created
- [ ] Confirm 9 namespaces
- [ ] Verify 9 Odoo deployments

### Step 4: Execute Deployment
```bash
make apply
```
- [ ] Terraform creates resources sequentially
- [ ] Minikube clusters starting (watch with `minikube status --all`)
- [ ] First cluster starts (5-10 minutes)
- [ ] All clusters created (20-30 minutes total)
- [ ] No errors in output

### Step 5: Post-Deployment Configuration
```bash
make post-apply
```
- [ ] /etc/hosts updated with domain mappings
- [ ] Backup created of original /etc/hosts
- [ ] All 9 domains added

### Step 6: Verify Deployments
```bash
make status
```
- [ ] All Minikube clusters running
- [ ] All 9 namespaces exist
- [ ] All deployments showing Ready status
- [ ] All services created

## Validation Testing

### Test 1: HTTPS Connectivity
```bash
make validate-deployment
```
- [ ] All 9 domains tested
- [ ] HTTPS connections successful
- [ ] 0 failed deployments

### Test 2: Individual Domains
```bash
# Test each client's environments
curl -k https://odoo.dev.airbnb.local/
curl -k https://odoo.prod.airbnb.local/
curl -k https://odoo.dev.nike.local/
curl -k https://odoo.qa.nike.local/
curl -k https://odoo.prod.nike.local/
curl -k https://odoo.dev.mcdonalds.local/
curl -k https://odoo.qa.mcdonalds.local/
curl -k https://odoo.beta.mcdonalds.local/
curl -k https://odoo.prod.mcdonalds.local/
```
- [ ] All 9 domains respond
- [ ] HTTPS protocol active
- [ ] Valid response codes (200/301/302)

### Test 3: Kubernetes Resources
```bash
kubectl get namespaces
kubectl get pods -A
kubectl get deployments -A
kubectl get ingress -A
kubectl get secrets -A
```
- [ ] 9 namespaces created (client-environment format)
- [ ] All pods in Running/Ready state
- [ ] All deployments showing 1/1 ready
- [ ] Ingress for each namespace
- [ ] TLS secrets present

### Test 4: Database Connectivity
```bash
# Test from Odoo pod
kubectl exec -it deployment/odoo -n airbnb-dev -- \
  psql -h postgres.airbnb-dev.svc.cluster.local -U odoo -d odoo -c "SELECT 1;"
```
- [ ] PostgreSQL responds
- [ ] Query returns successfully

## Access & Documentation

### Generate Access Information
```bash
make access-info
```
- [ ] All domain URLs displayed
- [ ] Default credentials shown
- [ ] Usage instructions provided

### Review Documentation
- [ ] README.md reviewed
- [ ] QUICK_REFERENCE.md bookmarked
- [ ] Troubleshooting section noted
- [ ] Makefile targets understood

## Operational Verification

### Test Monitoring
```bash
# Check logs
make logs-all

# Get cluster status
make status

# View access info
make access-info
```
- [ ] All logs retrievable without errors
- [ ] Status shows healthy clusters
- [ ] Access info comprehensive

### Test Scaling
```bash
# Add a new client to terraform/variables.tf
# Then run:
make plan
make apply
```
- [ ] New resources created successfully
- [ ] No conflicts with existing deployments

## Post-Deployment Checklist

### Operational Setup
- [ ] Team trained on Makefile commands
- [ ] Documentation shared with team
- [ ] Access credentials distributed securely
- [ ] Monitoring configured (if applicable)

### Backup & Recovery
- [ ] Terraform state backed up: `cp terraform/terraform.tfstate backup/`
- [ ] Recovery procedure documented
- [ ] Backup schedule planned

### Security Hardening
- [ ] Database password changed from default
- [ ] RBAC policies considered
- [ ] NetworkPolicies reviewed
- [ ] TLS certificate considerations noted

### Future Planning
- [ ] Plan for certificate renewal
- [ ] Schedule resource optimization review
- [ ] Plan for production upgrades
- [ ] Document any customizations

## Troubleshooting Verification

### Test Error Scenarios

#### Scenario 1: Cluster Restart
```bash
# Stop and restart a cluster
minikube stop -p airbnb-dev
minikube start -p airbnb-dev
# Verify Odoo still accessible
curl -k https://odoo.dev.airbnb.local/
```
- [ ] Cluster recovers
- [ ] Application accessible

#### Scenario 2: Pod Restart
```bash
# Delete an Odoo pod
kubectl delete pod -l app=odoo -n nike-qa
# Verify new pod starts
kubectl get pods -n nike-qa -w
# Verify application accessible
curl -k https://odoo.qa.nike.local/
```
- [ ] New pod automatically created
- [ ] Application recovers

#### Scenario 3: Database Recovery
```bash
# Delete PostgreSQL pod
kubectl delete pod postgres-0 -n mcdonalds-dev
# Verify recovery
kubectl get pods -n mcdonalds-dev
# Verify Odoo still works
curl -k https://odoo.dev.mcdonalds.local/
```
- [ ] Pod recovers
- [ ] Data persisted
- [ ] Application functional

## Sign-Off

- [ ] **Deployment Date**: ________________
- [ ] **Deployed By**: ________________
- [ ] **Reviewed By**: ________________
- [ ] **Approved By**: ________________

### Deployment Summary
- **Total Clusters Created**: 9
- **Total Namespaces**: 9
- **Total Pods**: ~30-40
- **Total Domains**: 9
- **All Tests Passed**: YES / NO
- **Production Ready**: YES / NO

### Notes
```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

## Rollback Procedure (if needed)

### Quick Rollback
```bash
make destroy
make clean
```
- [ ] All infrastructure destroyed
- [ ] Terraform state cleaned
- [ ] /etc/hosts cleaned

### Partial Rollback
To destroy only specific client:
```bash
cd terraform
terraform destroy -target='minikube_cluster.cluster["client-env"]'
terraform destroy -target='kubernetes_namespace.client_env["client-env"]'
```

## Monitoring & Maintenance

### Daily Checks
- [ ] All clusters healthy: `make status`
- [ ] All pods running: `kubectl get pods -A`
- [ ] No pending events: `kubectl get events -A`

### Weekly Tasks
- [ ] Review logs: `make logs-all`
- [ ] Validate deployments: `make validate-deployment`
- [ ] Backup Terraform state

### Monthly Tasks
- [ ] Review resource utilization
- [ ] Check certificate validity (365 days)
- [ ] Review security policies
- [ ] Test disaster recovery

---

**Deployment Checklist Version**: 1.0.0  
**Last Updated**: January 2026
