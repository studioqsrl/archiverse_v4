# Flux GitOps Configuration

This directory contains the configuration for Flux GitOps deployment with Azure Key Vault integration.

## Configuration Files

### workload-identity.yaml
- Configures Azure Workload Identity for the cluster
- Sets up a service account with proper Azure identity annotations
- Enables direct access to Azure Key Vault without requiring CSI drivers or secret mounting
- Uses client ID: 4b3ddf68-561e-451f-a92b-aded94cea508

### flux-config.yaml
- Core Flux configuration
- Defines the GitOps workflow settings

### deploy-monitor.sh
- Script for monitoring deployment status

## Azure Key Vault Integration

The cluster uses Azure Workload Identity to authenticate and access Azure Key Vault directly. This approach:
- Eliminates the need for CSI drivers and secret mounting
- Provides more direct and secure access to Azure services
- Simplifies the configuration by removing additional layers (like SecretProviderClass)

### How It Works

1. The Workload Identity configuration in `workload-identity.yaml`:
   - Creates a service account `flux-sa` in the `flux-system` namespace
   - Annotates it with the Azure Workload Identity client ID and tenant ID
   - Creates a service account token for authentication

2. This allows the cluster to:
   - Authenticate directly with Azure services
   - Access Key Vault secrets without intermediate mounting
   - Maintain a simpler and more secure configuration

### Available Secrets

The following secrets are available in the Azure Key Vault (`archiverse-kv`):

#### Authentication & Authorization
- `AUTH0-CLIENT-ID` - Auth0 application client ID
- `AUTH0-CLIENT-SECRET` - Auth0 application client secret
- `AUTH0-MANAGEMENT-API-DOMAIN` - Auth0 Management API domain
- `AUTH0-MANAGEMENT-CLIENT-ID` - Auth0 Management API client ID
- `AUTH0-MANAGEMENT-CLIENT-SECRET` - Auth0 Management API client secret
- `AUTH0-ADMIN-ROLE-ID` - Auth0 admin role identifier
- `AUTH0-MEMBER-ROLE-ID` - Auth0 member role identifier
- `NEXT-PUBLIC-AUTH0-DOMAIN` - Public Auth0 domain
- `CUSTOM-CLAIMS-NAMESPACE` - Namespace for custom claims
- `DEFAULT-CONNECTION-ID` - Default connection identifier

#### Database
- `postgres-user` - PostgreSQL username
- `postgres-password` - PostgreSQL password

#### Container Registry
- `acr-username` - Azure Container Registry username
- `acr-password` - Azure Container Registry password

#### Application
- `APP-BASE-URL` - Base URL for the application
- `SESSION-ENCRYPTION-SECRET` - Secret for session encryption
- `github-access-token` - GitHub access token for Flux

### Key Vault Access

To access secrets in Azure Key Vault:
1. Use the Azure CLI or SDK in your applications
2. Authenticate using the Workload Identity
3. Access secrets directly from Key Vault

Example using Azure CLI:
```bash
az keyvault secret show --vault-name archiverse-kv --name your-secret-name
```

## Maintenance

When adding new secrets:
1. Add them directly to Azure Key Vault
2. No additional Kubernetes configuration is needed
3. Applications can access secrets using Azure SDK or CLI
