# Flux Sync Sequence

```mermaid
sequenceDiagram
    participant Git as GitHub Repository
    participant ACR as Azure Container Registry
    participant Flux as Flux Controller
    participant K8s as Kubernetes Cluster

    Note over Git,K8s: Developer pushes code to main branch
    
    rect rgb(200, 220, 250)
        Note right of Git: Git Push Detection
        Git->>Flux: Git push detected
        activate Flux
        Note right of Flux: Within 1 minute
        Flux->>Git: Fetch latest changes
        Git-->>Flux: Return updated manifests
        Flux->>K8s: Apply manifest changes
        K8s-->>Flux: Sync status
        Note right of Flux: Verify deployment
        Flux->>K8s: Check resources health
        K8s-->>Flux: Health status
        deactivate Flux
        
        Note right of Git: If changes include Dockerfile
        Git->>ACR: Trigger container build
        activate ACR
        Note right of ACR: Build time: ~3-5 mins
        ACR-->>ACR: Build new container image
        ACR->>ACR: Push image to registry
        deactivate ACR
    end

    rect rgb(220, 250, 220)
        Note right of Flux: Image Update Workflow
        ACR->>Flux: New image detected
        activate Flux
        Note right of Flux: Within 1 minute
        Flux->>Git: Update image tags in manifests
        Git-->>Flux: Confirm update
        Note right of Flux: Verify image update
        Flux->>Git: Validate manifest changes
        Git-->>Flux: Validation status
        deactivate Flux
    end

    rect rgb(250, 220, 220)
        Note right of Flux: Final Verification
        activate Flux
        Note right of Flux: Health check
        Flux->>K8s: Verify all resources
        K8s-->>Flux: Resource status
        Note right of K8s: Check pods, services, etc.
        Flux->>K8s: Validate workload health
        K8s-->>Flux: Workload status
        deactivate Flux
    end

    Note over Git,K8s: Sync and verification complete within 1-2 minutes of git push
```

## Process Breakdown

1. **Initial Git Push Detection**: < 1 minute
   - Flux detects changes in Git repository
   - Fetches and validates new manifests
   - Applies initial manifest changes
   - Performs first health check

2. **Container Build** (if Dockerfile changes): ~3-5 minutes
   - ACR builds new container image
   - Pushes to registry
   - Triggers image update workflow

3. **Image Update Verification**: ~1 minute
   - Updates image tags in manifests
   - Validates manifest changes
   - Commits updates back to Git

4. **Final Health Verification**: ~1 minute
   - Comprehensive resource check
   - Validates all workload states
   - Confirms successful deployment

Note: While container builds take 3-5 minutes, manifest sync and verification complete within 1-2 minutes of git push. Container updates trigger a separate verification cycle.
