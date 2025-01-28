# Enterprise Kubernetes Infrastructure

This repository contains a production-grade Kubernetes infrastructure configuration following cloud-native best practices and the GitOps methodology using Flux.

## Architecture Overview

The infrastructure is managed using Flux CD for GitOps automation and Azure Service Operator for cloud resource management.

```
infrastructure/k8s/
├── azure/                     # Azure-specific configurations
│   └── service-operator/     # Azure Service Operator configurations
│       ├── namespace.yaml    # ASO namespace
│       ├── release.yaml      # Helm release
│       ├── repository.yaml   # Helm repository
│       └── flux-kustomization.yaml # Flux sync config
├── base/                     # Base configurations
│   ├── frontend/            # Frontend service
│   │   ├── frontend.yaml    # Deployment and service
│   │   └── kustomization.yaml
│   ├── backend/             # Backend service
│   │   ├── api.yaml        # API deployment
│   │   └── kustomization.yaml
│   ├── databases/           # Database configurations
│   │   ├── postgres.yaml   # PostgreSQL configuration
│   │   ├── service.yaml    # Database service
│   │   └── kustomization.yaml
│   └── namespaces/         # Namespace definitions
│       └── archiverse.yaml # Application namespace
├── platform/                 # Platform-level infrastructure
│   ├── flux-system/         # Flux GitOps components
│   │   ├── gotk-components.yaml # Flux core components
│   │   ├── gotk-sync.yaml      # Repository sync
│   │   └── kustomization.yaml
│   ├── istio/               # Service mesh configuration
│   │   └── gateway/        # Gateway configurations
│   │       ├── ingress.yaml
│   │       └── kustomization.yaml
│   └── security/           # Security infrastructure
│       ├── cert-manager/   # Certificate management
│       │   ├── cert-manager.yaml
│       │   ├── release.yaml
│       │   └── kustomization.yaml
│       └── vault/         # Secrets management
│           ├── secret-provider-class.yaml
│           ├── secrets.yaml
│           └── kustomization.yaml
└── overlays/               # Environment-specific configurations
    ├── development/       # Development environment
    │   ├── kustomization.yaml
    │   ├── configs/      # Environment configs
    │   ├── patches/      # Kustomize patches
    │   └── secrets/      # Sealed secrets
    ├── staging/          # Staging environment
    │   ├── kustomization.yaml
    │   ├── configs/
    │   ├── patches/
    │   └── secrets/
    └── production/        # Production environment
        ├── managed-cluster.yaml # AKS configuration
        ├── flux-kustomization.yaml # Flux sync
        ├── configs/
        ├── patches/
        └── secrets/
```

## Key Components

### GitOps with Flux

The infrastructure uses Flux CD for GitOps automation:
- Source control: GitHub repository sync
- Automated deployment: 10-minute sync interval
- Dependency management: Proper ordering of resource deployment
- Garbage collection: Automated pruning of removed resources

### Azure Integration

Azure resources are managed through the Azure Service Operator:
- AKS cluster management
- Azure resources provisioning
- Managed identities integration
- Azure service bindings

### Security Infrastructure

- cert-manager: Automated certificate management
- HashiCorp Vault: Secrets management
- Istio: Service mesh security

### Application Components

- Frontend service: Web application deployment
- Backend service: API service deployment
- Database: PostgreSQL configuration
- Service mesh: Istio gateway and routing

## Environment Management

The infrastructure supports multiple environments through Kustomize overlays:
- Development: Local development configuration
- Staging: Pre-production testing
- Production: Production deployment with AKS integration

Each environment can be customized using:
- Environment-specific configurations
- Kustomize patches
- Sealed secrets
- Resource overrides

## Getting Started

1. Ensure Flux is installed in your cluster
2. Configure Azure Service Operator credentials
3. Apply the base configuration:
   ```bash
   kubectl apply -k base/
   ```
4. Select and apply an environment overlay:
   ```bash
   kubectl apply -k overlays/development/
   ```

## Best Practices

- All changes should be made through Git
- Use Kustomize for environment-specific changes
- Secrets should be managed through Vault
- Follow the principle of least privilege
- Use namespaces for resource isolation
- Implement proper health checks
- Monitor Flux reconciliation status
