# Enterprise Architecture Platform Infrastructure

This directory contains the infrastructure configurations for the Enterprise Architecture Platform.

## Directory Structure

```
infrastructure/
├── containers/           # Container management
│   ├── README.md
│   ├── acr-task.yaml
│   ├── fix-issues.sh
│   ├── monitor-deployment.sh
│   ├── setup-acr-task.sh
│   └── test-build.sh
├── deployment/          # Continuous deployment
│   ├── gotk-sync.yaml
│   └── kustomization.yaml
├── identity/           # Identity and access management
│   ├── README.md
│   ├── README-ADVANCED.md
│   └── delete-auth0-resources.py
└── platform/          # Platform infrastructure
    ├── base/          # Base configurations
    │   ├── namespaces/
    │   │   └── archiverse.yaml
    │   ├── cert-manager.yaml
    │   ├── deployment.yaml
    │   ├── ingress.yaml
    │   ├── kustomization.yaml
    │   ├── secret-provider.yaml
    │   ├── secrets.yaml
    │   └── storage/   # Storage infrastructure
    │       ├── cassandra/
    │       │   ├── config/
    │       │   │   └── configmap.yaml
    │       │   ├── network-policy.yaml
    │       │   ├── service.yaml
    │       │   └── statefulset.yaml
    │       └── janusgraph/
    │           ├── config/
    │           │   └── configmap.yaml
    │           ├── network-policy.yaml
    │           ├── secret.yaml
    │           ├── service.yaml
    │           └── statefulset.yaml
    └── overlays/      # Environment-specific overrides
        ├── dev/
        │   ├── ingress-patch.yaml
        │   ├── kustomization.yaml
        │   └── secrets.yaml
        ├── staging/
        │   ├── ingress-patch.yaml
        │   ├── kustomization.yaml
        │   └── secrets.yaml
        └── prod/
            ├── ingress-patch.yaml
            ├── kustomization.yaml
            └── secrets.yaml
```

## Components

### Application Services
- **App Service**: FastAPI-based service that provides PostgreSQL data access
  - Deployed with the same node pool as frontend
  - Internal cluster communication via Service
  - Network policies for secure PostgreSQL access
  - Health monitoring and Auth0 integration

### Container Management (/containers)
- Container image build configurations
- Azure Container Registry (ACR) tasks
- Deployment monitoring
- Build testing and issue resolution

### Continuous Deployment (/deployment)
- GitOps configurations using Flux
- Automated synchronization
- Deployment tracking

### Identity Management (/identity)
- Authentication and authorization
- User management
- Resource access control
- Advanced identity configurations

### Data Persistence (/persistence)
- Database configurations and schemas
- Data storage policies
- Backup configurations

### Platform Infrastructure (/platform)
Core platform configurations organized into:

#### Base Configurations
- Namespace definitions
- Certificate management
- Ingress configurations
- Secret management
- Storage infrastructure:
  - Cassandra cluster
  - JanusGraph database

#### Environment Overlays
- Development (dev)
- Staging
- Production (prod)
Each with environment-specific:
- Ingress configurations
- Secret management
- Resource limits

## Storage Infrastructure

The storage layer is built on JanusGraph with Apache Cassandra as the backend storage engine.

### Cassandra
- StatefulSet running Apache Cassandra 4.1
- Configured for high availability with 3 replicas
- Includes network policies for secure communication
- Optimized for enterprise architecture workloads
- Persistent storage with 100Gi per node
- Resource limits: 4 CPU cores, 16Gi memory per node

### JanusGraph
- StatefulSet running JanusGraph latest version
- Configured for high availability with 3 replicas
- Optimized cache and transaction settings
- Secure communication with Cassandra backend
- Persistent storage with 50Gi per node
- Resource limits: 4 CPU cores, 8Gi memory per node

## Security Features

1. Network Policies
   - Restricted pod-to-pod communication
   - Isolated Cassandra cluster access
   - Controlled external access to JanusGraph

2. Authentication
   - Cassandra authentication enabled
   - Credentials managed via Kubernetes secrets
   - Secure password storage
   - Identity provider integration

## Deployment Instructions

1. Create the namespace:
   ```bash
   kubectl apply -f platform/base/namespaces/archiverse.yaml
   ```

2. Deploy Cassandra:
   ```bash
   kubectl apply -f platform/base/storage/cassandra/
   ```
   Wait for all Cassandra pods to be ready:
   ```bash
   kubectl rollout status statefulset/cassandra
   ```

3. Deploy JanusGraph:
   ```bash
   # First update the cassandra-credentials secret with secure passwords
   kubectl apply -f platform/base/storage/janusgraph/
   ```
   Wait for all JanusGraph pods to be ready:
   ```bash
   kubectl rollout status statefulset/janusgraph
   ```

4. Deploy App Service:
   ```bash
   kubectl apply -f platform/base/app-service.yaml
   ```
   Wait for the app service to be ready:
   ```bash
   kubectl rollout status deployment/app-service
   ```

## Environment Management

The infrastructure supports multiple environments through Kustomize overlays:

- `platform/overlays/dev/` - Development environment
- `platform/overlays/staging/` - Staging environment
- `platform/overlays/prod/` - Production environment

Each environment has its own:
- Ingress configurations
- Secret management
- Resource limits and scaling parameters

## Continuous Deployment

GitOps-based continuous deployment:
1. Infrastructure changes are committed to the repository
2. Flux automatically synchronizes the changes
3. Changes are applied to the cluster based on environment

## Container Management

Container lifecycle management:
1. Automated builds via ACR tasks
2. Image vulnerability scanning
3. Deployment monitoring
4. Issue resolution scripts

## Monitoring

Monitor the health of your infrastructure:

```bash
# Check Cassandra cluster status
kubectl exec cassandra-0 -- nodetool status

# Check JanusGraph pods
kubectl get pods -l app=janusgraph

# Monitor deployments
./containers/monitor-deployment.sh

# Check App Service status
kubectl get pods -l app=app-service
kubectl logs -l app=app-service
kubectl get service app-service
```

## Best Practices

1. Always maintain at least 3 replicas for high availability
2. Monitor disk usage and scale storage as needed
3. Regularly update security credentials
4. Keep JanusGraph and Cassandra versions in sync
5. Implement regular backup procedures
6. Monitor performance metrics and adjust resources accordingly
7. Use environment overlays for configuration differences
8. Follow GitOps workflow for infrastructure changes

## Support

For issues or questions:
1. Check pod logs: `kubectl logs <pod-name>`
2. Review events: `kubectl get events`
3. Consult component-specific documentation
4. Use provided monitoring and debugging scripts
