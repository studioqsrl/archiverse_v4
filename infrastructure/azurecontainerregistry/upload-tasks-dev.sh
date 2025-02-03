#!/bin/bash

# Exit on any error
set -e

echo "Deleting existing ACR tasks from archiversedev..."

# Delete existing tasks if they exist
az acr task delete --name "frontend-dev-build" --registry "archiversedev" --yes || true
az acr task delete --name "app-service-dev-build" --registry "archiversedev" --yes || true

echo "Creating ACR tasks in archiversedev..."

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN environment variable is not set"
  exit 1
fi

# Frontend task
echo "Creating frontend dev task..."
az acr task create \
  --name "frontend-dev-build" \
  --registry "archiversedev" \
  --context "https://github.com/studioqsrl/archiverse_v4.git#main" \
  --file "frontend/Dockerfile" \
  --git-access-token "${GITHUB_TOKEN}" \
  --commit-trigger-enabled true \
  --platform "linux/arm64/v8" \
  --image "frontend-dev:{{.Run.ID}}" \
  --image "frontend-dev:latest" \
  --verbose

# App Service task
echo "Creating app service dev task..."
az acr task create \
  --name "app-service-dev-build" \
  --registry "archiversedev" \
  --file "backend/app_service/Dockerfile" \
  --context "https://github.com/studioqsrl/archiverse_v4.git#main" \
  --git-access-token "${GITHUB_TOKEN}" \
  --commit-trigger-enabled true \
  --platform "linux/arm64/v8" \
  --image "app-service-dev:{{.Run.ID}}" \
  --image "app-service-dev:latest" \
  --verbose

echo "All dev tasks have been created successfully!"