# Cloud Computing Platform

Multi-client Kubernetes infrastructure managed with Terraform. Deploy isolated Odoo ERP environments for multiple enterprise clients.

## Description

This project implements a **scalable cloud infrastructure platform** that provisions and manages isolated Kubernetes environments for multiple enterprise clients. Each client receives their own dedicated Minikube cluster with multiple environments (Dev, QA, Beta, Prod), ensuring complete resource isolation and independent lifecycle management.

### Key Features

- **Multi-tenancy**: Each client has a dedicated Kubernetes cluster with isolated namespaces per environment
- **Infrastructure as Code**: 100% Terraform-managed infrastructure with zero manual configuration
- **Dynamic Scaling**: Add new clients or environments by simply editing a variables file
- **HTTPS by Default**: Self-signed TLS certificates automatically generated for all endpoints
- **Full Stack Deployment**: Complete Odoo ERP + PostgreSQL stack per environment
- **One Command Setup**: `make bootstrap` deploys the entire platform from scratch

### Current Clients

| Client | Environments | Total Deployments |
|--------|--------------|-------------------|
| AirBnB | Dev, Prod | 2 |
| Nike | Dev, QA, Prod | 3 |
| McDonalds | Dev, QA, Beta, Prod | 4 |

**Total**: 3 clusters, 9 namespaces, 9 Odoo instances, 9 PostgreSQL databases

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          CLOUD COMPUTING PLATFORM                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────┐    │
│   │     AIRBNB      │  │      NIKE       │  │       MCDONALDS         │    │
│   │   (2 envs)      │  │    (3 envs)     │  │        (4 envs)         │    │
│   ├─────────────────┤  ├─────────────────┤  ├─────────────────────────┤    │
│   │ minikube-airbnb │  │  minikube-nike  │  │   minikube-mcdonalds    │    │
│   │                 │  │                 │  │                         │    │
│   │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐          │    │
│   │  │    DEV    │  │  │  │    DEV    │  │  │  │    DEV    │          │    │
│   │  │  Odoo+PG  │  │  │  │  Odoo+PG  │  │  │  │  Odoo+PG  │          │    │
│   │  └───────────┘  │  │  └───────────┘  │  │  └───────────┘          │    │
│   │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐          │    │
│   │  │   PROD    │  │  │  │    QA     │  │  │  │    QA     │          │    │
│   │  │  Odoo+PG  │  │  │  │  Odoo+PG  │  │  │  │  Odoo+PG  │          │    │
│   │  └───────────┘  │  │  └───────────┘  │  │  └───────────┘          │    │
│   │                 │  │  ┌───────────┐  │  │  ┌───────────┐          │    │
│   │                 │  │  │   PROD    │  │  │  │   BETA    │          │    │
│   │                 │  │  │  Odoo+PG  │  │  │  │  Odoo+PG  │          │    │
│   │                 │  │  └───────────┘  │  │  └───────────┘          │    │
│   │                 │  │                 │  │  ┌───────────┐          │    │
│   │                 │  │                 │  │  │   PROD    │          │    │
│   │                 │  │                 │  │  │  Odoo+PG  │          │    │
│   │                 │  │                 │  │  └───────────┘          │    │
│   └─────────────────┘  └─────────────────┘  └─────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Quick Start

### One Command Setup

```bash
make bootstrap
```

This single command will:
1. Initialize Terraform and create workspaces
2. Deploy all clients (Airbnb, Nike, McDonalds)
3. Update `/etc/hosts` with domain mappings
4. Validate all deployments via HTTPS

### Manual Setup

```bash
# 1. Initialize
make init

# 2. Deploy all clients
make apply-all

# 3. Update DNS entries
make hosts-update

# 4. Validate
make validate
```

## Access URLs

After deployment, access Odoo at:

| Client | Environment | URL |
|--------|-------------|-----|
| AirBnB | Dev | https://odoo.dev.airbnb.local |
| AirBnB | Prod | https://odoo.prod.airbnb.local |
| Nike | Dev | https://odoo.dev.nike.local |
| Nike | QA | https://odoo.qa.nike.local |
| Nike | Prod | https://odoo.prod.nike.local |
| McDonalds | Dev | https://odoo.dev.mcdonalds.local |
| McDonalds | QA | https://odoo.qa.mcdonalds.local |
| McDonalds | Beta | https://odoo.beta.mcdonalds.local |
| McDonalds | Prod | https://odoo.prod.mcdonalds.local |

> **Note**: Use `curl -k` or accept the self-signed certificate warning in your browser.

## Project Structure

```
cloud-computing-project/
├── terraform/           # Infrastructure as Code
│   ├── variables.tf     # Client/environment definitions
│   ├── locals.tf        # Dynamic mappings
│   ├── providers.tf     # Kubernetes provider config
│   ├── minikube.tf      # Cluster provisioning
│   ├── namespaces.tf    # K8s namespaces
│   ├── postgres.tf      # PostgreSQL StatefulSets
│   ├── odoo.tf          # Odoo Deployments
│   ├── tls.tf           # TLS certificates
│   ├── secrets.tf       # K8s secrets
│   ├── ingress.tf       # HTTPS ingress
│   └── outputs.tf       # Terraform outputs
├── scripts/             # Automation scripts
│   ├── init-workspaces.sh
│   ├── apply-all.sh
│   ├── destroy-all.sh
│   ├── update-hosts.sh
│   └── validate.sh
├── Makefile             # Build automation
└── README.md
```

## Makefile Commands

### Quick Start
```bash
make bootstrap           # Complete setup from scratch
```

### Deployment
```bash
make init                # Initialize Terraform
make apply-all           # Deploy all clients
make destroy-all         # Destroy all infrastructure
```

### Per Client
```bash
make apply-<client>      # Deploy specific client
make destroy-<client>    # Destroy specific client
make plan-<client>       # Preview changes
make validate-<client>   # Validate client

# Available clients: airbnb, nike, mcdonalds
```

### Utilities
```bash
make validate            # Validate all HTTPS endpoints
make hosts-update        # Update /etc/hosts
make hosts-status        # Show current hosts entries
make status              # Show clusters & workspaces
make clean               # Clean Terraform files
```

## Adding a New Client

1. Edit `terraform/variables.tf`:

```hcl
variable "clients" {
  default = {
    airbnb    = { environments = ["dev", "prod"] }
    nike      = { environments = ["dev", "qa", "prod"] }
    mcdonalds = { environments = ["dev", "qa", "beta", "prod"] }
    
    # Add new client
    starbucks = { environments = ["dev", "staging", "prod"] }
  }
}
```

2. Deploy:

```bash
make apply-starbucks     # Or add to apply-all.sh
make hosts-update
make validate
```

## Tech Stack

- **Infrastructure**: Terraform
- **Kubernetes**: Minikube (1 cluster per client)
- **Application**: Odoo 16 ERP
- **Database**: PostgreSQL 15
- **Ingress**: NGINX Ingress Controller
- **TLS**: Self-signed certificates

## Requirements

- Docker
- Minikube
- Terraform >= 1.0
- kubectl
- ~20GB RAM (for all 3 clients)
- ~10 vCPUs

## Troubleshooting

### Pods not starting
```bash
kubectl get pods -A
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

### HTTPS not working
```bash
# Check hosts file
cat /etc/hosts | grep odoo

# Update if needed
make hosts-update

# Check ingress
kubectl get ingress -A
```

### Check cluster status
```bash
make status
minikube profile list
```

### Reset everything
```bash
make destroy-all
make clean
make bootstrap
```

## License

MIT License - See [LICENSE](LICENSE) for details.
