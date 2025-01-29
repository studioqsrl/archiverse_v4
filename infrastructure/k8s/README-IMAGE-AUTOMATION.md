# Frontend Image Deployment Strategy

This document describes how frontend container images are deployed across different environments using Flux.

## Image Tagging Strategy

We use a hybrid approach for managing container image tags:

### Base Configuration
- Located in: `base/frontend/frontend.yaml`
- Uses untagged image reference: `archiverseacr.azurecr.io/frontend`
- Tags are set by environment-specific overlays

### Development Environment
- Located in: `overlays/development/`
- Uses Flux image automation to track Run.ID tags
- Automatically updates when new images are built by ACR tasks
- Configuration:
  - ImageRepository: Monitors ACR for new images
  - ImagePolicy: Uses numerical ordering for Run.ID tags
  - ImageUpdateAutomation: Updates Git repository automatically

### Production Environment
- Located in: `overlays/production/`
- Uses explicit, immutable version tags (e.g., v1.0.0)
- Tags are updated manually through Pull Requests
- Ensures controlled, reproducible deployments

## Deployment Workflow

### Development
1. ACR Task builds new image with Run.ID tag:
   ```yaml
   # infrastructure/azurecontainerregistry/frontend-task.yaml
   name: frontend-build
   image: frontend:{{.Run.ID}}
   ```

2. Flux automatically:
   - Detects new image in ACR
   - Updates development overlay
   - Commits and pushes changes
   - Deploys new version

### Production
1. Test new version in development environment
2. Create PR to update production image tag:
   ```yaml
   # infrastructure/k8s/overlays/production/patches/frontend-image.yaml
   spec:
     template:
       spec:
         containers:
         - name: app-pool
           image: archiverseacr.azurecr.io/frontend:v1.0.0
   ```
3. Review and merge PR
4. Flux applies changes to production cluster

## Verification

Check deployment status:
```bash
# Get current image versions
kubectl get deployment frontend -n archiverse -o=jsonpath='{.spec.template.spec.containers[0].image}'

# Check Flux image automation
flux get image all -A

# Check image repository
flux get image repository frontend -n flux-system

# Check image policy
flux get image policy frontend -n flux-system
```

## Troubleshooting

### Development Environment
1. Image not updating:
   ```bash
   # Check image repository status
   flux get image repository frontend -n flux-system
   
   # Check image policy
   flux get image policy frontend -n flux-system
   
   # Check automation status
   flux get image update frontend -n flux-system
   ```

2. Check pod status:
   ```bash
   kubectl describe pod -n archiverse -l app=frontend
   ```

### Production Environment
1. Before updating image tag:
   - Verify image exists in ACR
   - Test image in development environment
   - Follow semantic versioning for tags

2. After updating:
   ```bash
   # Check deployment rollout
   kubectl rollout status deployment/frontend -n archiverse
   
   # Check pod status
   kubectl get pods -n archiverse -l app=frontend
