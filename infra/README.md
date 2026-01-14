# ZavaStorefront Infrastructure

This directory contains the Azure infrastructure definition for the ZavaStorefront web application using Azure Bicep templates and Azure Developer CLI (AZD).

## Architecture Overview

The infrastructure deploys the following Azure resources in West US 3:

- **Resource Group**: Container for all resources
- **Azure Container Registry (ACR)**: Stores Docker images with RBAC authentication
- **App Service Plan**: Linux-based hosting plan (B2 tier)
- **App Service**: Web application host with container support
- **Application Insights**: Application performance monitoring
- **Log Analytics Workspace**: Centralized logging
- **Azure OpenAI Service**: AI capabilities with GPT-4 and embedding models

## Key Features

- ✅ **Containerized Deployment**: Docker-based deployment without local Docker requirement
- ✅ **RBAC Security**: Managed Identity authentication between services
- ✅ **Monitoring**: Application Insights with Log Analytics integration
- ✅ **AI Ready**: Azure OpenAI with GPT-4 and text embeddings
- ✅ **Infrastructure as Code**: Bicep templates with AZD orchestration

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Developer CLI (AZD)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
- Azure subscription with appropriate permissions

## Deployment

### 1. Initialize Environment

```bash
# Initialize AZD (run from repository root)
azd init

# Set environment name
azd env set AZURE_ENV_NAME "zava-dev"
azd env set AZURE_LOCATION "westus3"
```

### 2. Login and Deploy

```bash
# Login to Azure
azd auth login

# Preview infrastructure changes
azd provision --preview

# Deploy infrastructure and application
azd up
```

### 3. Verify Deployment

```bash
# Check deployment status
azd show

# View resource group in Azure Portal
az group show --name rg-zava-dev --output table
```

## Build and Deploy Application

The infrastructure supports remote container builds using ACR Tasks:

```bash
# Build container image remotely
az acr build --registry <acr-name> \
  --image zava-storefront:latest \
  --file src/Dockerfile src/

# Deploy updated container
azd deploy
```

## Configuration

Key application settings configured automatically:

- `APPLICATIONINSIGHTS_CONNECTION_STRING`: Monitoring telemetry
- `AZURE_OPENAI_ENDPOINT`: AI service endpoint
- `ASPNETCORE_ENVIRONMENT`: Application environment
- `DOCKER_REGISTRY_SERVER_URL`: Container registry URL

## Security

- **Managed Identity**: App Service uses system-assigned identity
- **RBAC Roles**: 
  - `AcrPull`: Container Registry image access
  - `Cognitive Services OpenAI User`: AI service access
- **HTTPS Only**: All web traffic encrypted
- **No Passwords**: Zero password-based authentication

## Monitoring

Access monitoring through:

- **Application Insights**: Real-time performance metrics
- **Log Analytics**: Centralized log aggregation
- **Azure Portal**: Resource health and metrics

## Cleanup

```bash
# Remove all resources
azd down --force --purge
```

## Troubleshooting

### Common Issues

1. **Container Registry Access**: Ensure Managed Identity has AcrPull role
2. **Application Startup**: Check container logs in App Service
3. **AI Services**: Verify region availability for OpenAI models

### Useful Commands

```bash
# Check App Service logs
az webapp log tail --name <app-name> --resource-group <rg-name>

# Test container registry access
az acr repository list --name <acr-name>

# View role assignments
az role assignment list --assignee <principal-id>
```