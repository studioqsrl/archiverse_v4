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

echo -e "${BLUE}Starting test build process...${NC}"

# Add build timestamp to Dockerfile
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
echo -e "\n# Build timestamp: $timestamp" >> ../../Dockerfile

# Commit and push the change
echo -e "\n${BLUE}Committing and pushing changes...${NC}"
git add ../../Dockerfile
git commit -m "test: add build timestamp $timestamp"
git push

echo -e "\n${GREEN}Changes pushed. Starting deployment monitor...${NC}"

# Start monitoring the deployment
./monitor-deployment.sh
