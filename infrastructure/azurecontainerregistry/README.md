# Azure Container Registry Tasks

This directory contains the configuration files and documentation for Azure Container Registry (ACR) tasks that build and push Docker images for the Archiverse application.

## Task Configurations

### App Service Task
- **File**: `app-service-task.yaml`
- **Purpose**: Builds and pushes the Python FastAPI backend service
- **Important Notes**:
  - Uses repository root as context to ensure proper file access
  - Dockerfile paths are relative to repository root
  - Example: `COPY backend/app_service/requirements.txt .`

### Frontend Task
- **File**: `frontend-task.yaml`
- **Purpose**: Builds and pushes the Next.js frontend application
- **Important Notes**:
  - Uses repository root as context to ensure proper file access
  - Dockerfile paths are relative to repository root
  - Example: `COPY frontend/package*.json ./`

## Common Issues and Solutions

### File Not Found During Build
If you encounter "file not found" errors during the build:
1. Ensure the context in the task YAML is set to the repository root:
   ```yaml
   context: https://github.com/studioqsrl/archiverse_v4.git#main
   ```
2. Update COPY commands in Dockerfile to include the full path from repository root:
   ```dockerfile
   # Instead of
   COPY ./requirements.txt .
   
   # Use
   COPY backend/app_service/requirements.txt .
   ```

### Auth0 Integration Issues
When building the frontend, you might encounter Auth0 integration errors:

```
Error: You cannot mix creating your own instance with `initAuth0` and using named exports like `import { handleAuth } from '@auth0/nextjs-auth0'`
```

This occurs because Auth0's Next.js SDK doesn't support mixing different initialization methods. To resolve this:

1. Use consistent Auth0 initialization throughout the application
2. If using `appClient` (custom instance), use its methods instead of named exports:
   ```typescript
   // Instead of
   import { getSession } from "@auth0/nextjs-auth0"
   
   // Use
   import { appClient } from "@/lib/auth0"
   const session = await appClient.getSession()
   ```

## Running Tasks

To run a task manually:

```bash
# Build app service
az acr task run --registry archiverseacr --name app-service-build

# Build frontend
az acr task run --registry archiverseacr --name frontend-build
```

## Task Structure
Each task YAML file contains:
- `name`: Unique identifier for the task
- `registry`: Target ACR instance
- `image`: Output image name and tag template
- `file`: Path to Dockerfile (relative to repository root)
- `context`: Git repository URL and branch
- `git-access-token`: GitHub access token for repository access
- `verbose`: Enable detailed logging

## Best Practices
1. Always use repository root as context to ensure consistent file access
2. Update file paths in Dockerfiles to be relative to repository root
3. Test builds locally before pushing changes
4. Monitor build logs for any Auth0 or dependency-related issues
5. Keep Dockerfile paths and context configurations in sync
