# Flux Multi-Environment Setup

## Separate Cluster per Environment

### Architecture

- Each environment requires its own Kubernetes cluster:
  - Development cluster
  - Staging cluster
  - Production cluster

- Each cluster has its own Flux installation
- Each Flux installation points to its specific overlay path

### Flux Bootstrap Configuration

For each cluster, configure Flux to point to the correct overlay path:

```bash
# Development Cluster
flux bootstrap github \
  --path=infrastructure/k8s/overlays/development

# Staging Cluster
flux bootstrap github \
  --path=infrastructure/k8s/overlays/staging

# Production Cluster
flux bootstrap github \
  --path=infrastructure/k8s/overlays/production
```

This ensures:
- Environment isolation
- No resource conflicts
- Independent deployment pipelines
- Clear promotion path through environments

## Kustomize Structure

```
infrastructure/k8s/
├── base/              # Shared base configurations
├── overlays/          # Environment-specific overlays
│   ├── development/
│   ├── staging/
│   └── production/
└── platform/         # Platform-wide configurations
```

Each environment inherits from base and applies its specific customizations through overlays.
