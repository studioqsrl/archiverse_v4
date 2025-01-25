# Infrastructure Architecture

## Overview
This directory contains the infrastructure configuration for the Archiverse project, managed through GitOps using Flux. The infrastructure is deployed on Azure Kubernetes Service (AKS) and follows a declarative approach where all changes are version controlled and automatically synchronized to the cluster.

## Directory Structure
```
infrastructure/
├── cluster/                 # Kubernetes manifests
│   ├── base/               # Base configurations
│   │   ├── deployment.yaml # Main application deployment
│   │   ├── ingress.yaml   # Ingress configuration
│   │   └── cert-manager.yaml # TLS certificate management
│   └── overlays/          # Environment-specific configurations
│       ├── dev/           # Development environment
│       ├── staging/       # Staging environment
│       └── prod/          # Production environment
└── flux-system/           # Flux GitOps configuration
    ├── gotk-sync.yaml     # Git repository synchronization
    └── kustomization.yaml # Flux system configuration

```

## Components

### 1. GitOps with Flux
- **Repository**: https://github.com/studioqsrl/archiverse_v4
- **Branch**: main
- **Path**: ./infrastructure/cluster/base
- **Sync Interval**: 10 minutes
- **Prune**: Enabled (removes deleted resources)

#### Flux Components:
- **Source Controller**: Monitors Git repository for changes
- **Kustomize Controller**: Applies Kubernetes manifests
- **Image Automation Controllers**:
  - Image Reflector: Scans container registry for new images
  - Image Automation: Updates manifests with new image versions

### 2. Container Registry
- **Type**: Azure Container Registry (ACR)
- **Name**: archiverseacr.azurecr.io
- **Authentication**: Managed through Kubernetes secrets

### 3. Kubernetes Resources
- **Namespace**: archiverse
- **Deployments**: 
  - Main application (archiverse)
  - Resource limits and requests configured
  - Health checks implemented
- **Services**: ClusterIP service exposing port 3000
- **Ingress**: Azure Application Gateway
  - Host: archiverse.studioq.biz
  - TLS enabled
  - Managed by cert-manager

### 4. Automation Flow

#### Infrastructure Changes
1. Changes committed to Git repository
2. Flux detects changes in infrastructure/cluster/base
3. Changes automatically applied to cluster
4. Status reported back through Flux

#### Application Updates
1. New code pushed to application repository
2. GitHub Actions builds new container image
3. Image pushed to Azure Container Registry
4. Flux Image Automation:
   - Detects new image in ACR
   - Updates deployment manifest in Git
   - Changes synchronized to cluster

### 5. Security
- Private GitHub repository
- Private Azure Container Registry
- Kubernetes RBAC enabled
- Secrets management through Kubernetes secrets
- TLS certificates managed by cert-manager

### 6. Monitoring
- GitOps status visible in Azure Portal
- Flux provides status through custom resources:
  - GitRepository
  - Kustomization
  - ImageRepository
  - ImagePolicy
  - ImageUpdateAutomation

## Development Workflow

### Making Infrastructure Changes
1. Clone repository
2. Create branch
3. Modify files in infrastructure/cluster/
4. Commit and push changes
5. Create pull request
6. After merge, Flux automatically applies changes

### Deploying Application Updates
1. Push code changes
2. GitHub Actions builds and pushes new image
3. Flux automatically:
   - Detects new image
   - Updates deployment manifest
   - Applies changes to cluster

## Troubleshooting

### Common Commands
```bash
# Check Flux status
flux get all

# Check image automation
kubectl get imagerepositories,imagepolicies,imageupdateautomations -n flux-system

# View application status
kubectl get pods,services,ingress -n archiverse

# View Flux logs
kubectl logs -n flux-system deploy/source-controller
kubectl logs -n flux-system deploy/kustomize-controller
kubectl logs -n flux-system deploy/image-reflector-controller
kubectl logs -n flux-system deploy/image-automation-controller
```

### Common Issues
1. Image not updating:
   - Check ACR authentication
   - Verify ImageRepository can scan registry
   - Check ImagePolicy configuration

2. Changes not applying:
   - Verify Flux can access Git repository
   - Check Flux controller logs
   - Verify kustomization path is correct

## Best Practices
1. Always use specific image tags, avoid 'latest'
2. Test changes in dev environment first
3. Use pull requests for infrastructure changes
4. Keep secrets out of Git
5. Monitor Flux status regularly
6. Review automation logs periodically
