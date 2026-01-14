targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string = 'westus3'

@description('Id of the user or app to assign application roles')
param principalId string = ''

// Optional parameters
@description('Name of the resource group. Leave empty to use default naming convention.')
param resourceGroupName string = ''

@description('Name of the container registry. Leave empty to use default naming convention.')
param containerRegistryName string = ''

@description('Name of the app service. Leave empty to use default naming convention.')
param appServiceName string = ''

@description('Name of the Application Insights. Leave empty to use default naming convention.')
param applicationInsightsName string = ''

@description('Name of the Log Analytics workspace. Leave empty to use default naming convention.')
param logAnalyticsName string = ''

@description('Name of the AI services. Leave empty to use default naming convention.')
param aiServicesName string = ''

// Variables
var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
  'azd-project-name': 'zava-storefront'
}

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// Container Registry
module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'containerRegistry'
  scope: rg
  params: {
    name: !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    tags: tags
  }
}

// Log Analytics workspace
module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  scope: rg
  params: {
    name: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    location: location
    tags: tags
  }
}

// Application Insights
module applicationInsights 'modules/applicationInsights.bicep' = {
  name: 'applicationInsights'
  scope: rg
  params: {
    name: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
    tags: tags
  }
}

// AI Services
module aiServices 'modules/aiServices.bicep' = {
  name: 'aiServices'
  scope: rg
  params: {
    name: !empty(aiServicesName) ? aiServicesName : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    location: location
    tags: tags
  }
}

// App Service
module appService 'modules/appService.bicep' = {
  name: 'appService'
  scope: rg
  params: {
    name: !empty(appServiceName) ? appServiceName : '${abbrs.webSitesAppService}${resourceToken}'
    location: location
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    containerRegistryName: containerRegistry.outputs.name
    aiServicesEndpoint: aiServices.outputs.endpoint
    tags: tags
  }
}

// RBAC assignments
module rbac 'modules/rbac.bicep' = {
  name: 'rbac'
  scope: rg
  params: {
    containerRegistryName: containerRegistry.outputs.name
    appServicePrincipalId: appService.outputs.identityPrincipalId
    aiServicesName: aiServices.outputs.name
  }
}

// App outputs
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = rg.name

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name

output SERVICE_WEB_NAME string = appService.outputs.name
output SERVICE_WEB_URI string = appService.outputs.uri
output SERVICE_WEB_IDENTITY_PRINCIPAL_ID string = appService.outputs.identityPrincipalId

output APPLICATIONINSIGHTS_CONNECTION_STRING string = applicationInsights.outputs.connectionString

output AZURE_OPENAI_ENDPOINT string = aiServices.outputs.endpoint
output AZURE_OPENAI_SERVICE_NAME string = aiServices.outputs.name
