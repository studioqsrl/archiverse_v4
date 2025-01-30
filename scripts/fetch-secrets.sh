#!/bin/bash
set -e

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Azure CLI is required but not installed. Please install it first."
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo "Please log in to Azure first using: az login"
    exit 1
fi

# Required environment variables
if [ -z "$AZURE_KEYVAULT_NAME" ]; then
    echo "Error: AZURE_KEYVAULT_NAME environment variable is required"
    exit 1
fi

# Create .env file
echo "# Generated from Azure KeyVault on $(date)" > .env
echo "# KeyVault: $AZURE_KEYVAULT_NAME" >> .env
echo "" >> .env

# Function to fetch secret or use default
fetch_secret() {
    local secret_name=$1
    local env_name=$2
    local default_value=$3
    
    value=$(az keyvault secret show --vault-name "$AZURE_KEYVAULT_NAME" --name "$secret_name" --query value -o tsv 2>/dev/null || echo "$default_value")
    echo "$env_name=$value" >> .env
}

# Database credentials
echo "# Database configuration" >> .env
fetch_secret "postgres-host" "POSTGRES_HOST" "localhost"
fetch_secret "postgres-db" "POSTGRES_DB" "archiverse"
fetch_secret "postgres-user" "POSTGRES_USER" "postgres"
fetch_secret "postgres-password" "POSTGRES_PASSWORD" "development-password-only"
echo "" >> .env

# Application configuration
echo "# Application configuration" >> .env
fetch_secret "app-base-url" "APP_BASE_URL" "http://localhost:3000"
echo "" >> .env

# Auth0 configuration
echo "# Auth0 configuration" >> .env
fetch_secret "auth0-domain" "NEXT_PUBLIC_AUTH0_DOMAIN" "your-auth0-domain.auth0.com"
fetch_secret "custom-claims-namespace" "NEXT_PUBLIC_CUSTOM_CLAIMS_NAMESPACE" "https://archiverse.io"
echo "" >> .env

# Auth0 secrets
echo "# Auth0 secrets" >> .env
fetch_secret "auth0-client-id" "AUTH0_CLIENT_ID" ""
fetch_secret "auth0-client-secret" "AUTH0_CLIENT_SECRET" ""
fetch_secret "auth0-management-client-id" "AUTH0_MANAGEMENT_CLIENT_ID" ""
fetch_secret "auth0-management-client-secret" "AUTH0_MANAGEMENT_CLIENT_SECRET" ""
fetch_secret "auth0-admin-role-id" "AUTH0_ADMIN_ROLE_ID" ""
fetch_secret "auth0-member-role-id" "AUTH0_MEMBER_ROLE_ID" ""
fetch_secret "default-connection-id" "DEFAULT_CONNECTION_ID" ""
fetch_secret "session-encryption-secret" "SESSION_ENCRYPTION_SECRET" ""

echo "Secrets have been fetched and saved to .env"
echo "WARNING: This file contains sensitive information. Do not commit it to version control."
