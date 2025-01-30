# Archiverse

## Secrets Management

### Local Development

For local development, you need a `.env` file with the required configuration. You have two options:

1. **Use Development Values**
   - Copy `.env.example` to `.env`
   - Fill in the values for local development
   ```bash
   cp .env.example .env
   ```

2. **Use Production Values**
   - Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
   - Log in to Azure:
   ```bash
   az login
   ```
   - Set your KeyVault name:
   ```bash
   export AZURE_KEYVAULT_NAME=your-keyvault-name
   ```
   - Run the fetch script:
   ```bash
   ./scripts/fetch-secrets.sh
   ```
   This will create a `.env` file with all secrets from Azure KeyVault.

### Production Environment

In production, secrets are managed through:
1. Azure KeyVault for secure storage
2. Kubernetes External Secrets Operator for synchronization
3. Kubernetes Secrets for application access

The configuration is split into:
- `infrastructure/keyvault/secrets.yaml`: Defines all secrets in Azure KeyVault
- `infrastructure/k8s/base/secrets.yaml`: Configures K8s secret management

### Secret Categories

1. **Database Credentials**
   - POSTGRES_HOST
   - POSTGRES_DB
   - POSTGRES_USER
   - POSTGRES_PASSWORD

2. **Auth0 Configuration**
   - AUTH0_CLIENT_ID
   - AUTH0_CLIENT_SECRET
   - AUTH0_MANAGEMENT_CLIENT_ID
   - AUTH0_MANAGEMENT_CLIENT_SECRET
   - AUTH0_ADMIN_ROLE_ID
   - AUTH0_MEMBER_ROLE_ID
   - DEFAULT_CONNECTION_ID
   - SESSION_ENCRYPTION_SECRET

3. **Application Configuration**
   - APP_BASE_URL
   - NEXT_PUBLIC_AUTH0_DOMAIN
   - NEXT_PUBLIC_CUSTOM_CLAIMS_NAMESPACE

### Security Notes

1. Never commit `.env` files to version control
2. Use `fetch-secrets.sh` only on secure development machines
3. Rotate secrets regularly through Azure KeyVault
4. Keep development and production configurations separate
