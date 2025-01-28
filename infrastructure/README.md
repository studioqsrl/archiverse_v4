# Enterprise Architecture Platform Infrastructure

This directory contains the infrastructure configurations for the Enterprise Architecture Platform.

## Directory Structure

```
infrastructure/
├── azurecontainerregistry/  # Azure Container Registry configuration
│   ├── app-service-task.yaml
│   ├── frontend-task.yaml
│   └── upload-tasks.sh
├── identity/                # Identity and access management
│   ├── README.md
│   ├── README-ADVANCED.md
│   └── delete-auth0-resources.py
├── k8s/                    # Kubernetes configurations
│   ├── base/               # Base configurations
│   │   ├── namespaces/
│   │   │   └── archiverse.yaml
│   │   ├── app-pool/      # Application services
│   │   │   ├── api.yaml
│   │   │   └── frontend.yaml
│   │   ├── db-pool/       # Database configurations
│   │   │   ├── config.yaml
│   │   │   ├── postgres.yaml
│   │   │   ├── service-account.yaml
│   │   │   └── service.yaml
│   │   ├── cert-manager.yaml
│   │   ├── ingress.yaml
│   │   ├── kustomization.yaml
│   │   └── secret-provider-class.yaml
│   └── overlays/          # Environment-specific overrides
│       ├── dev/
│       │   ├── ingress-patch.yaml
│       │   ├── kustomization.yaml
│       │   └── secrets.yaml
│       ├── staging/
│       │   ├── ingress-patch.yaml
│       │   ├── kustomization.yaml
│       │   └── secrets.yaml
│       └── prod/
│           ├── ingress-patch.yaml
│           ├── kustomization.yaml
│           └── secrets.yaml
└── keyvault/              # Azure Key Vault configuration
    └── secrets.yaml
```

## GitOps with Flux

The infrastructure is managed using Flux, a GitOps tool that ensures the cluster state matches the desired state defined in this repository.

### Flux Bootstrap

To set up Flux with GitHub authentication:

```bash
# Bootstrap Flux with GitHub authentication
flux bootstrap github \
  --token-auth \
  --owner=studioqsrl \
  --repository=archiverse_v4 \
  --branch=main \
  --path=infrastructure/k8s/overlays/prod \
  --components-extra=image-reflector-controller,image-automation-controller
```

This setup:
- Uses GitHub token-based authentication
- Monitors the main branch
- Applies configurations from the production overlay
- Includes image automation components for automated deployments

### Key Components

#### Base Configuration (/k8s/base)
- Namespace definitions
- Certificate management (cert-manager)
- Ingress configurations
- Secret provider integration
- Application services configuration
- Database configurations

#### Environment Overlays (/k8s/overlays)
Each environment (dev, staging, prod) has specific configurations for:
- Ingress settings
- Environment-specific secrets
- Resource limits and scaling
- Image tags and versions

## Azure Integration

### Azure Container Registry
- Automated build tasks
- Image vulnerability scanning
- Deployment monitoring

### Azure Key Vault
- Secure secret management
- Integration with Kubernetes via CSI driver
- Managed identity authentication

## Application Components

### Frontend Service
- Next.js-based web application
- Deployed in the app pool
- Exposed via Azure Application Gateway ingress

### API Service
- FastAPI-based backend service
- Internal cluster communication
- Secure database access
- Health monitoring and Auth0 integration

### Database
- PostgreSQL database
- Dedicated node pool
- Automated backups
- Resource isolation

## Security Features

1. Network Security
   - Pod-to-pod communication policies
   - Ingress traffic control
   - Secure service communication

2. Authentication & Authorization
   - Auth0 integration
   - Azure AD integration
   - RBAC policies

3. Secret Management
   - Azure Key Vault integration
   - CSI secret provider
   - Secure credential rotation

## Deployment Process

The GitOps workflow ensures automated deployment:

1. Changes are committed to the repository
2. Flux detects changes and reconciles the cluster state
3. Changes are applied based on the environment overlay
4. Status can be checked using Flux commands:
   ```bash
   # Check Flux status
   flux get kustomizations
   
   # Check sources
   flux get sources git
   
   # Check reconciliation
   flux get all
   ```

## Monitoring

Monitor infrastructure health:

```bash
# Check pod status
kubectl get pods -n archiverse

# View application logs
kubectl logs -l app=frontend -n archiverse
kubectl logs -l app=api -n archiverse

# Check services
kubectl get services -n archiverse

# Monitor ingress
kubectl get ingress -n archiverse
```

## Best Practices

1. Follow GitOps workflow for all infrastructure changes
2. Use environment overlays for configuration differences
3. Keep secrets in Azure Key Vault
4. Regularly update security credentials
5. Monitor resource usage and scale as needed
6. Implement regular backup procedures
7. Use proper tagging for all resources
8. Maintain documentation for configuration changes

## Support

For troubleshooting:
1. Check pod logs: `kubectl logs <pod-name> -n archiverse`
2. Review events: `kubectl get events -n archiverse`
3. Check Flux status: `flux get all`
4. Verify Azure resources in portal
5. Review application logs in Azure Monitor
