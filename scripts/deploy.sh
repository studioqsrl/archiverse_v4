#!/bin/bash

# Exit on any error
set -e

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required commands
for cmd in git az kubectl; do
    if ! command_exists "$cmd"; then
        echo "Error: $cmd is required but not installed."
        exit 1
    fi
done

# Function to monitor ACR task and get image ID
wait_for_acr_run() {
    local task_name=$1
    local registry="archiverseacr"
    local max_attempts=60  # 10 minutes maximum wait time
    local attempt=0
    
    echo "Waiting for ACR task $task_name to start..."
    
    # Wait for the task to start
    while [ $attempt -lt $max_attempts ]; do
        run_id=$(az acr task list-runs --registry $registry --query "[?taskName=='$task_name' && status=='Running'].runId | [0]" -o tsv)
        
        if [ ! -z "$run_id" ]; then
            echo "Found running task with ID: $run_id"
            break
        fi
        
        echo "No running task found... waiting (attempt $((attempt + 1))/$max_attempts)"
        sleep 10
        attempt=$((attempt + 1))
    done
    
    if [ -z "$run_id" ]; then
        echo "Error: No running task found after $max_attempts attempts"
        exit 1
    fi
    
    # Monitor the running task
    echo "Monitoring run ID: $run_id"
    while true; do
        status=$(az acr task show-run --registry $registry --run-id $run_id --query status -o tsv)
        if [ "$status" == "Succeeded" ]; then
            echo "Task completed successfully!"
            # Get the image ID from the run
            image_id=$(az acr task show-run --registry $registry --run-id $run_id --query runId -o tsv)
            echo "New image ID: $image_id"
            echo "$image_id"
            break
        elif [ "$status" == "Failed" ] || [ "$status" == "Canceled" ]; then
            echo "Task failed or was canceled"
            exit 1
        fi
        echo "Status: $status... waiting"
        sleep 10
    done
}

# Git operations
echo "Committing and pushing changes..."
git add .
git commit -m "Update frontend" || true
git push

# Monitor frontend build
echo "Monitoring frontend build..."
frontend_image_id=$(wait_for_acr_run "frontend-build")

# Monitor backend build
echo "Monitoring backend build..."
backend_image_id=$(wait_for_acr_run "app-service-build")

# Update the production overlays
echo "Updating production overlays with new image IDs..."

# Update frontend image
frontend_overlay="infrastructure/k8s/overlays/production/patches/frontend-image.yaml"
if [ ! -f "$frontend_overlay" ]; then
    echo "Error: Frontend overlay file not found at $frontend_overlay"
    exit 1
fi
echo "Updating frontend image tag..."
sed -i '' "s|archiverseacr.azurecr.io/frontend:.*|archiverseacr.azurecr.io/frontend:${frontend_image_id}|g" "$frontend_overlay"

# Update backend image
backend_overlay="infrastructure/k8s/overlays/production/patches/app-service-image.yaml"
if [ ! -f "$backend_overlay" ]; then
    echo "Error: Backend overlay file not found at $backend_overlay"
    exit 1
fi
echo "Updating backend image tag..."
sed -i '' "s|archiverseacr.azurecr.io/app-service:.*|archiverseacr.azurecr.io/app-service:${backend_image_id}|g" "$backend_overlay"

# Commit and push the overlay updates
echo "Committing and pushing overlay updates..."
git add "$frontend_overlay" "$backend_overlay"
git commit -m "Update frontend image to ${frontend_image_id} and backend image to ${backend_image_id}"
git push

# Flux sync
echo "Triggering Flux sync..."
kubectl flux reconcile source git flux-system
kubectl flux reconcile kustomization flux-system

echo "Deployment completed successfully!"
