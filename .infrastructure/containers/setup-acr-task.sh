#!/bin/bash

# Exit on error
set -e

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "Error: .env file not found. Copy .env.example to .env and configure your settings."
    exit 1
fi

# Validate required variables
required_vars=("ACR_NAME" "ACR_RESOURCE_GROUP" "GITHUB_TOKEN" "GITHUB_REPO" "TASK_NAME")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var environment variable is required"
        exit 1
    fi
done

echo "Creating ACR Task..."

# Create the task with GitHub integration
az acr task create \
    --name "$TASK_NAME" \
    --registry "$ACR_NAME" \
    --resource-group "$ACR_RESOURCE_GROUP" \
    --context "https://github.com/$GITHUB_REPO" \
    --file acr-task.yaml \
    --git-access-token "$GITHUB_TOKEN" \
    --auth-mode None

echo "Task created successfully!"

# Show how to manually trigger the task
echo "
You can manually trigger the task with:
az acr task run --name $TASK_NAME --registry $ACR_NAME --resource-group $ACR_RESOURCE_GROUP

To view task runs:
az acr task list-runs --registry $ACR_NAME --resource-group $ACR_RESOURCE_GROUP
"
