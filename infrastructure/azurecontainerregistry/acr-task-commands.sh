#!/bin/bash
# ACR Task Management Commands
#
# This script manages Azure Container Registry (ACR) tasks for the Archiverse project.
# It creates and configures tasks for building and testing services.
#
# Prerequisites:
# - Azure CLI installed and logged in
# - Access to archiverseacr container registry
# - Required YAML task definition files in infrastructure/azurecontainerregistry/
#
# Usage:
#   ./acr-task-commands.sh
#
# The script will:
# 1. Delete any existing tasks with the same names
# 2. Create all required tasks with proper configurations
# 3. List all tasks after creation
# 4. Show commands for running individual tasks
#
# Note: All tasks are created with system-managed identities and
# have git triggers disabled by default.

# Variables
REGISTRY="archiverseacr"
REPO="https://github.com/studioqsrl/archiverse_v4.git#main"

# Delete existing tasks if needed
echo "Deleting existing tasks..."
az acr task delete --name app-service --registry $REGISTRY --yes
az acr task delete --name frontend --registry $REGISTRY --yes
az acr task delete --name kvtest --registry $REGISTRY --yes
az acr task delete --name verbose --registry $REGISTRY --yes

# Create app-service task
echo "Creating app-service task..."
az acr task create \
    --name app-service \
    --registry $REGISTRY \
    --file infrastructure/azurecontainerregistry/app-service-task.yaml \
    --context $REPO \
    --assign-identity '[system]' \
    --commit-trigger-enabled false \
    --pull-request-trigger-enabled false \
    --base-image-trigger-enabled false

# Create frontend task
echo "Creating frontend task..."
az acr task create \
    --name frontend \
    --registry $REGISTRY \
    --file infrastructure/azurecontainerregistry/frontend-task.yaml \
    --context $REPO \
    --assign-identity '[system]' \
    --commit-trigger-enabled false \
    --pull-request-trigger-enabled false \
    --base-image-trigger-enabled false

# Create Key Vault test task
echo "Creating Key Vault test task..."
az acr task create \
    --name kvtest \
    --registry $REGISTRY \
    --file infrastructure/azurecontainerregistry/test-task.yaml \
    --context /dev/null \
    --assign-identity '[system]' \
    --commit-trigger-enabled false \
    --pull-request-trigger-enabled false \
    --base-image-trigger-enabled false

# Create verbose task
echo "Creating verbose task..."
az acr task create \
    --name verbose \
    --registry $REGISTRY \
    --file infrastructure/azurecontainerregistry/verbose-task.yaml \
    --context $REPO \
    --assign-identity '[system]' \
    --commit-trigger-enabled false \
    --pull-request-trigger-enabled false \
    --base-image-trigger-enabled false

# List all tasks
echo "Listing all tasks..."
az acr task list --registry $REGISTRY -o table

# Optional: Run commands
echo "# To run individual tasks, use these commands:"
echo "az acr task run --name app-service --registry $REGISTRY"
echo "az acr task run --name frontend --registry $REGISTRY"
echo "az acr task run --name kvtest --registry $REGISTRY"
echo "az acr task run --name verbose --registry $REGISTRY"
