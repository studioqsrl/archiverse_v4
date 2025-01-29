#!/bin/bash

# Exit on any error
set -e

echo "Deleting existing ACR tasks from archiverseacr..."

# Delete existing tasks if they exist
az acr task delete --name "frontend-build" --registry "archiverseacr" --yes || true
az acr task delete --name "app-service-build" --registry "archiverseacr" --yes || true

echo "Creating ACR tasks in archiverseacr..."

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN environment variable is not set"
  exit 1
fi

# Frontend task
echo "Creating frontend task..."
az acr task create \
  --name "frontend-build" \
  --registry "archiverseacr" \
  --context "https://github.com/studioqsrl/archiverse_v4.git#main" \
  --file "infrastructure/azurecontainerregistry/frontend-task.yaml" \
  --git-access-token "${GITHUB_TOKEN}" \
  --commit-trigger-enabled true \
  --verbose

# App Service task
echo "Creating app service task..."
az acr task create \
  --name "app-service-build" \
  --registry "archiverseacr" \
  --image "app-service:{{.Run.ID}}" \
  --file "backend/app_service/Dockerfile" \
  --context "https://github.com/studioqsrl/archiverse_v4.git#main" \
  --git-access-token "${GITHUB_TOKEN}" \
  --commit-trigger-enabled true \
  --verbose

echo "All tasks have been created successfully!"
