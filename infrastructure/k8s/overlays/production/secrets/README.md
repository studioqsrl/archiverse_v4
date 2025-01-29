# Kubernetes Secrets Management

This directory contains scripts for managing Kubernetes secrets. The secrets are populated from Azure Key Vault and stored as Kubernetes secrets.

## Setup

1. Ensure you have the Azure CLI installed and are logged in
2. Make sure you have access to the Azure Key Vault `archiverse-kv`

## Creating Secrets

Run the `create-secrets.sh` script to fetch secrets from Azure Key Vault and create them in Kubernetes:

```bash
./create-secrets.sh
```

This will:
1. Fetch all secrets from Azure Key Vault
2. Create a Kubernetes secret manifest file
3. Apply the manifest to create/update the secrets in the cluster

## Important Notes

- The secrets manifest file (secrets.yaml) is generated but not committed to git for security reasons
- Always run the script to recreate secrets after cluster creation or if secrets need to be updated
- The script will maintain the same secret names but convert them to lowercase with underscores
