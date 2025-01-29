# Frontend Image Deployment Strategy

This document describes how frontend container images are deployed across different environments using Flux.

## Overview

We use a hybrid approach for deploying frontend images:
- **Development**: Automated updates via Flux image automation
- **Production**: Manual updates via Pull Requests

## Directory Structure

```
infrastructure/k8s/
├── base/
│   └── frontend/
│       ├── frontend.yaml      # Base deployment configuration
│       └── kustomization.yaml
├── overlays/
    ├── development/
    │   ├── configs/
    │   │   └── frontend-automation.yaml  # Flux image automation config
    │   ├── patches/
    │   │   └── frontend-image.yaml       # Development image patch
    │   └── kustomization.yaml
    └── production/
        ├── patches/
        │   └── frontend-image.yaml       # Production image patch
        └── kustomization.yaml
```

## Development Environment

The development environment uses Flux image automation for continuous deployment:

1. **Image Repository Scanning**
   - Monitors ACR for new frontend images
   - Configuration: `overlays/development/configs/frontend-automation.yaml`

2. **Automated Updates**
   - Automatically updates when new images are pushed to ACR
   - Updates are committed to the development branch
   - Uses image policy marker in `overlays/development/patches/frontend-image.yaml`

## Production Environment

Production uses a controlled, manual update process:

1. **Manual Image Updates**
   - Image tags are explicitly set in `overlays/production/patches/frontend-image.yaml`
   - Changes require Pull Requests
   - Provides review opportunity before deployment

2. **Update Process**
   ```bash
   # 1. Create a new branch
   git checkout -b update-frontend-version

   # 2. Update the image tag in
   infrastructure/k8s/overlays/production/patches/frontend-image.yaml

   # 3. Create PR, review, and merge
   ```

## Deployment Flow

1. **New Image Build**
   - ACR task builds new frontend image
   - Tags image with unique Run.ID

2. **Development Deployment**
   - Flux detects new image in ACR
   - Automatically updates development environment
   - Changes committed to development branch

3. **Production Deployment**
   - Create PR to update production image tag
   - Review changes and test impact
   - Merge PR to deploy to production

## Verification

Check deployment status:
```bash
# Get current image versions
kubectl get deployment frontend -n archiverse -o=jsonpath='{.spec.template.spec.containers[0].image}'

# Check Flux image automation status
flux get image all -A
```

## Troubleshooting

1. **Image Not Updating in Development**
   - Check image repository scanning:
     ```bash
     flux get image repository frontend -n flux-system
     ```
   - Verify image policy:
     ```bash
     flux get image policy frontend -n flux-system
     ```

2. **Production Deployment Issues**
   - Verify image exists in ACR
   - Check deployment status:
     ```bash
     kubectl describe deployment frontend -n archiverse
