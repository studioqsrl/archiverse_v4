# Flux Image Automation

This document describes the image automation setup for the Archiverse project using Flux.

## Overview

Flux is configured to automatically scan our Azure Container Registry (ACR) for new images and update the deployments accordingly.

## Components

### 1. ACR Authentication

Authentication to ACR is handled via a Kubernetes secret:

```bash
# Create the docker-registry secret in flux-system namespace
kubectl create secret docker-registry regcred -n flux-system \
  --docker-server=archiverseacr.azurecr.io \
  --docker-username=archiverseacr \
  --docker-password=<acr-password>
```

### 2. ACR Tasks Configuration

The ACR tasks are configured to build and push two tags for each image:
- A unique tag using the Run ID (`{{.Run.ID}}`)
- The 'latest' tag which is automatically updated with each successful build

### 3. Image Repository Configuration

The ImageRepository resource (`configs/frontend-repository.yaml`) is configured to scan our ACR:

```yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageRepository
metadata:
  name: frontend
  namespace: flux-system
spec:
  image: archiverseacr.azurecr.io/frontend
  interval: 1m0s
  secretRef:
    name: regcred
  provider: azure
```

This configuration:
- Scans the ACR repository every minute
- Uses the `regcred` secret for authentication
- Specifies Azure as the provider for ACR-specific authentication

### 3. Image Policy

The ImagePolicy resource (`configs/frontend-policy.yaml`) defines which tags to use:

```yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImagePolicy
metadata:
  name: frontend
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: frontend
  policy:
    alphabetical:
      order: asc
```

This configuration selects the 'latest' tag for automated updates.

## Verification

You can verify the setup using these commands:

```bash
# Check ImageRepository status
kubectl get imagerepositories.image.toolkit.fluxcd.io -n flux-system frontend -o yaml

# Check ImagePolicy status
kubectl get imagepolicies.image.toolkit.fluxcd.io -n flux-system frontend -o yaml
```

A successful configuration will show:
- ImageRepository scanning ACR successfully
- ImagePolicy resolving the latest tag correctly

## Troubleshooting

If image scanning fails:

1. Verify the secret exists and has correct credentials:
```bash
kubectl get secret -n flux-system regcred
```

2. Check ImageRepository logs:
```bash
kubectl logs -n flux-system deployment/image-reflector-controller
```

3. Ensure the ACR repository exists and is accessible:
```bash
az acr repository show -n archiverseacr --repository frontend
