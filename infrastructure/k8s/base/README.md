# Kubernetes Base Configuration

This directory contains the base Kubernetes configurations for the Archiverse platform.

## Node Pools Architecture

The cluster is organized into specialized node pools, each optimized for specific workloads:

### System Pool
- **Purpose**: Runs system components (Flux, cert-manager, etc.)
- **Size**: 1 node
- **Instance Type**: Standard_B2ps_v2 (ARM)
- **Mode**: System
- **Auto-scaling**: Disabled

### Frontend Pool
- **Purpose**: Runs Next.js frontend applications
- **Size**: 2-5 nodes
- **Instance Type**: Standard_B2ps_v2 (ARM)
- **Mode**: User
- **Auto-scaling**: Enabled
- **Taint**: `workload=frontend:NoSchedule`
- **Resources per pod**:
  - Requests: 100m CPU, 256Mi memory
  - Limits: 500m CPU, 512Mi memory

### Backend Pool
- **Purpose**: Runs FastAPI app service
- **Size**: 2-5 nodes
- **Instance Type**: Standard_B2ps_v2 (ARM)
- **Mode**: User
- **Auto-scaling**: Enabled
- **Taint**: `workload=appservice:NoSchedule`
- **Resources per pod**:
  - Requests: 100m CPU, 256Mi memory
  - Limits: 500m CPU, 512Mi memory

### Database Pool
- **Purpose**: Runs PostgreSQL database
- **Size**: 1 node
- **Instance Type**: Standard_B2ps_v2 (ARM)
- **Mode**: User
- **Auto-scaling**: Disabled
- **Taint**: `workload=postgres:NoSchedule`
- **Resources per pod**:
  - Requests: 250m CPU, 512Mi memory
  - Limits: 500m CPU, 1Gi memory

## Directory Structure

```
base/
├── frontend-pool/    # Frontend application configurations
│   └── frontend.yaml
├── backend-pool/     # Backend service configurations
│   └── api.yaml
├── db-pool/         # Database configurations
│   ├── config.yaml
│   ├── postgres.yaml
│   ├── service.yaml
│   └── service-account.yaml
├── namespaces/      # Namespace definitions
├── node-pools.yaml  # Node pool definitions
├── cert-manager.yaml
├── ingress.yaml
├── kustomization.yaml
└── secret-provider-class.yaml
```

## Workload Placement

Workloads are placed on specific node pools using a combination of node selectors and tolerations:

### Frontend Deployment
```yaml
nodeSelector:
  nodepool: frontend-pool
tolerations:
- key: workload
  operator: Equal
  value: frontend
  effect: NoSchedule
```

### Backend Deployment
```yaml
nodeSelector:
  nodepool: backend-pool
tolerations:
- key: workload
  operator: Equal
  value: appservice
  effect: NoSchedule
```

### Database StatefulSet
```yaml
nodeSelector:
  nodepool: db-pool
tolerations:
- key: workload
  operator: Equal
  value: postgres
  effect: NoSchedule
```

## Network Policies

Each component has specific network policies:

- Frontend can only communicate with backend API
- Backend can only communicate with database
- Database only accepts connections from backend
- All pods can access DNS

## Resource Management

All workloads are configured with resource requests and limits optimized for ARM architecture:

- Minimal resource allocation for cost efficiency
- Appropriate limits to prevent resource contention
- Auto-scaling enabled for frontend and backend pools to handle load variations

## GitOps Management

Node pools and workload configurations are managed through Flux GitOps:

1. Node pool changes:
   ```bash
   # Apply changes
   git commit -am "update: adjust node pool configuration"
   git push

   # Monitor reconciliation
   flux get kustomizations
   ```

2. Verify node pool status:
   ```bash
   kubectl get nodes --label-columns=nodepool
   ```

3. Check workload distribution:
   ```bash
   kubectl get pods -o wide
   ```

## Best Practices

1. Always use node selectors and tolerations for workload placement
2. Keep system pool dedicated to system components
3. Monitor resource usage and adjust limits as needed
4. Use network policies to restrict communication
5. Leverage auto-scaling for variable workloads
6. Maintain separate pools for different workload types
7. Use ARM instances for cost optimization
