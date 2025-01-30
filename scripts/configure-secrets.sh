#!/bin/bash
set -e

# Check if running in CI/CD pipeline
if [ -z "$CI" ]; then
    echo "This script is intended to run in a CI/CD pipeline"
    exit 1
fi

# Required environment variables
required_vars=(
    "AZURE_TENANT_ID"
    "AZURE_SUBSCRIPTION_ID"
    "AZURE_KEYVAULT_NAME"
    "ENVIRONMENT"
)

# Check required variables
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: Required environment variable $var is not set"
        exit 1
    fi
done

# Configure Azure CLI with service principal
az login --service-principal \
    --username "$AZURE_CLIENT_ID" \
    --password "$AZURE_CLIENT_SECRET" \
    --tenant "$AZURE_TENANT_ID"

# Select subscription
az account set --subscription "$AZURE_SUBSCRIPTION_ID"

# Install External Secrets Operator if not present
if ! kubectl get crd externalsecrets.external-secrets.io > /dev/null 2>&1; then
    echo "Installing External Secrets Operator..."
    helm repo add external-secrets https://charts.external-secrets.io
    helm repo update
    helm install external-secrets external-secrets/external-secrets
fi

# Wait for CRDs to be ready
kubectl wait --for=condition=established --timeout=60s \
    crd/externalsecrets.external-secrets.io \
    crd/secretstores.external-secrets.io

# Create namespace if it doesn't exist
kubectl create namespace archiverse --dry-run=client -o yaml | kubectl apply -f -

# Apply base secrets configuration
kubectl apply -f infrastructure/k8s/base/secrets.yaml

# Configure Azure KeyVault credentials
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: azure-secret-creds
  namespace: archiverse
type: Opaque
stringData:
  client-id: "$AZURE_CLIENT_ID"
  client-secret: "$AZURE_CLIENT_SECRET"
EOF

# Wait for secrets to sync
echo "Waiting for secrets to sync..."
kubectl wait --for=condition=ready --timeout=60s \
    externalsecret/app-secrets-sync \
    externalsecret/auth-secrets-sync \
    -n archiverse

echo "Secrets configuration completed successfully"
