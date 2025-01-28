# Node Pool Management

Node pools in the Archiverse cluster are managed using Azure CLI commands. This approach provides better control and compatibility with AKS features compared to using CRDs.

## Node Pool Configuration

The cluster uses the following node pools:

1. System Pool
   - Purpose: System workloads and cluster services
   - Size: 1 node
   - VM Size: Standard_B2ps_v2
   - Zone: 1
   - No autoscaling

2. Frontend Pool
   - Purpose: Frontend workloads
   - Size: 2-5 nodes (autoscaling)
   - VM Size: Standard_B2ps_v2
   - Zones: 1, 2
   - Taint: workload=frontend:NoSchedule

3. Backend Pool
   - Purpose: API services
   - Size: 2-5 nodes (autoscaling)
   - VM Size: Standard_B2ps_v2
   - Zones: 1, 2
   - Taint: workload=appservice:NoSchedule

4. DB Pool
   - Purpose: PostgreSQL database
   - Size: 1 node
   - VM Size: Standard_B2ps_v2
   - Zone: 1
   - Taint: workload=postgres:NoSchedule

## Managing Node Pools

Use the provided script to manage node pools:

```bash
# Apply node pool configuration
./apply-nodepools.sh

# List node pools
az aks nodepool list --cluster-name archiverse --resource-group archiverse

# Delete a node pool
az aks nodepool delete --name poolname --cluster-name archiverse --resource-group archiverse
```

## Node Pool Updates

When updating node pool configurations:

1. Edit the configuration in `apply-nodepools.sh`
2. Delete the existing node pool
3. Apply the new configuration

Note: For system pool updates, ensure you have at least one system pool available at all times to maintain cluster functionality.
