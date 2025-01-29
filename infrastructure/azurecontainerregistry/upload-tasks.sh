#!/bin/bash

# Exit on any error
set -e

echo "Deleting existing ACR tasks from archiverseacr..."

# Delete existing tasks if they exist
az acr task delete --name "frontend-build" --registry "archiverseacr" --yes || true
az acr task delete --name "app-service-build" --registry "archiverseacr" --yes || true

echo "Creating ACR tasks in archiverseacr..."

# Frontend task
echo "Creating frontend task..."
az acr task create \
  --name "frontend-build" \
  --registry "archiverseacr" \
  --image "frontend:{{.Run.ID}}" \
  --file "frontend/Dockerfile" \
  --context "https://github.com/studioqsrl/archiverse_v4.git#main" \
  --git-access-token "$GITHUB_TOKEN" \
  --platform "linux/arm64" \
  --verbose

# App Service task
echo "Creating app service task..."
az acr task create \
  --name "app-service-build" \
  --registry "archiverseacr" \
  --image "app-service:{{.Run.ID}}" \
  --file "backend/app_service/Dockerfile" \
  --context "https://github.com/studioqsrl/archiverse_v4.git#main" \
  --git-access-token "$GITHUB_TOKEN" \
  --verbose

echo "All tasks have been created successfully!"
