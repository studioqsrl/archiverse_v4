#!/bin/bash

# Exit on error
set -e

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "Error: .env file not found"
    exit 1
fi

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting deployment monitoring...${NC}"

# Monitor ACR Task
echo -e "\n${BLUE}Monitoring ACR Task build...${NC}"
task_run_id=$(az acr task list-runs --registry $ACR_NAME --resource-group $ACR_RESOURCE_GROUP --output json | jq -r '.[0].runId')
echo "Latest task run ID: $task_run_id"

az acr task logs --registry $ACR_NAME --run-id $task_run_id

# Wait for task completion
while true; do
    status=$(az acr task list-runs --registry $ACR_NAME --resource-group $ACR_RESOURCE_GROUP --output json | jq -r '.[0].status')
    if [ "$status" = "Succeeded" ]; then
        echo -e "${GREEN}Build completed successfully${NC}"
        break
    elif [ "$status" = "Failed" ] || [ "$status" = "Error" ]; then
        echo "Build failed with status: $status"
        exit 1
    fi
    echo "Build status: $status"
    sleep 10
done

# Monitor Flux sync
echo -e "\n${BLUE}Monitoring Flux sync...${NC}"
while true; do
    reconcile_status=$(flux get kustomization archiverse-flux-infrastructure | grep "Ready" | awk '{print $2}')
    if [ "$reconcile_status" = "True" ]; then
        echo -e "${GREEN}Flux sync completed${NC}"
        break
    fi
    echo "Flux sync status: $reconcile_status"
    sleep 10
done

# Monitor deployment rollout
echo -e "\n${BLUE}Monitoring deployment rollout...${NC}"
kubectl rollout status deployment/archiverse -n archiverse

echo -e "\n${GREEN}Deployment process completed successfully!${NC}"

# Show deployment status
echo -e "\n${BLUE}Current deployment status:${NC}"
kubectl get pods -n archiverse
echo -e "\nImage tag being used:"
kubectl get deployment archiverse -n archiverse -o jsonpath='{.spec.template.spec.containers[0].image}'
