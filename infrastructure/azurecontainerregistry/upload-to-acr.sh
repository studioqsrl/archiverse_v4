#!/bin/bash
set -e

REGISTRY="archiverseacr"
REGISTRY_URL="$REGISTRY.azurecr.io"

echo "Building and uploading images to ACR..."

# Build and push app-service
echo "Building app-service..."
docker build \
  -t "$REGISTRY_URL/app-service:latest" \
  -f backend/app_service/Dockerfile \
  --platform linux/arm64 \
  backend/app_service

echo "Pushing app-service..."
docker push "$REGISTRY_URL/app-service:latest"

# Build and push frontend
echo "Building frontend..."
docker build \
  -t "$REGISTRY_URL/frontend:latest" \
  -f frontend/Dockerfile \
  --platform linux/arm64 \
  .

echo "Pushing frontend..."
docker push "$REGISTRY_URL/frontend:latest"

echo "All images built and pushed successfully!"
