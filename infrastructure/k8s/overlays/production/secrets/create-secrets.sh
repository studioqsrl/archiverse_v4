#!/bin/bash

# Create the output directory if it doesn't exist
mkdir -p infrastructure/k8s/overlays/production/secrets

# Start creating the secret manifest
echo "Fetching secrets from Key Vault..."
echo "apiVersion: v1
kind: Secret
metadata:
  name: archiverse-secrets
  namespace: archiverse
type: Opaque
stringData:" > infrastructure/k8s/overlays/production/secrets/secrets.yaml

# Add each secret to the manifest
secrets=$(az keyvault secret list --vault-name archiverse-kv --query "[].name" -o tsv)
for secret in $secrets; do
    value=$(az keyvault secret show --vault-name archiverse-kv --name "$secret" --query value -o tsv)
    # Convert secret name to the format we want (lowercase with underscores)
    formatted_name=$(echo "$secret" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
    echo "  $formatted_name: \"$value\"" >> infrastructure/k8s/overlays/production/secrets/secrets.yaml
done

echo "Created secrets manifest at infrastructure/k8s/overlays/production/secrets/secrets.yaml"
