#!/bin/bash
set -e

REGISTRY="archiverseacr"

echo "Testing all ACR tasks..."

# Function to create and run a task
create_and_run_task() {
    local task_name=$1
    local yaml_file=$2
    
    echo "Testing $task_name..."
    echo "Creating task..."
    
    # Delete task if it exists
    az acr task delete \
        --name "$task_name" \
        --registry "$REGISTRY" \
        --yes || true
    
    # Create task
    az acr task create \
        --name "$task_name" \
        --registry "$REGISTRY" \
        --file "$yaml_file" \
        --context https://github.com/studioqsrl/archiverse_v4.git#main \
        --assign-identity '[system]' \
        --commit-trigger-enabled false \
        --pull-request-trigger-enabled false \
        --base-image-trigger-enabled false
    
    echo "Running task..."
    # Run task
    az acr task run \
        --name "$task_name" \
        --registry "$REGISTRY"
    
    echo "$task_name test completed"
    echo "----------------------------------------"
}

# Test app-service task
create_and_run_task "app-service" "app-service-task.yaml"

# Test frontend task
create_and_run_task "frontend" "frontend-task.yaml"

# Test verbose task
create_and_run_task "verbose" "verbose-task.yaml"

# Test key vault access task
create_and_run_task "key-vault-test" "test-task.yaml"

echo "All tasks tested successfully!"
