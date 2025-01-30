# Azure KeyVault Secret Management

This directory contains configuration for managing secrets in Azure KeyVault.

## Architecture

Secrets are managed using a multi-layered approach:

1. **Development Environment**
   - Uses `.env` files for local development
   - Sample configuration in `.env.example`
   - Secrets are never committed to version control

2. **Production Environment**
   - Secrets stored in Azure KeyVault
   - External Secrets Operator syncs to Kubernetes
   - Automatic rotation for supported secrets

## Secret Categories

1. **Database Credentials**
   - Stored in Azure KeyVault
   - Synced to Kubernetes via External Secrets
   - Rotated automatically by Azure

2. **Auth0 Configuration**
   - Public configuration exposed via environment variables
   - Private secrets stored in Azure KeyVault
   - Synced to Kubernetes secrets

3. **Application Secrets**
   - Session encryption keys
   - API tokens
   - Managed through Azure KeyVault

## Setup Instructions

1. Install External Secrets Operator in your cluster:
   ```bash
   helm repo add external-secrets https://charts.external-secrets.io
   helm install external-secrets external-secrets/external-secrets
   ```

2. Configure Azure KeyVault access:
   - Create a managed identity for your AKS cluster
   - Grant necessary KeyVault permissions
   - Configure External Secrets Operator

3. Apply Kubernetes configurations:
   ```bash
   kubectl apply -f ../k8s/base/secrets.yaml
   ```

## Secret Rotation

- Database credentials: Automated by Azure
- Auth0 secrets: Manual rotation through Auth0 dashboard
- Session secrets: Manual rotation with zero-downtime deployment

## Security Best Practices

1. Use separate KeyVault instances for different environments
2. Implement least-privilege access control
3. Enable audit logging for all secret access
4. Regular rotation of all secrets
5. Separate public and private configurations
