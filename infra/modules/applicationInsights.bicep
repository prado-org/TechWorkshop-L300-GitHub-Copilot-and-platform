@description('The name of the application insights resource')
param name string

@description('The location into which the resources should be deployed')
param location string = resourceGroup().location

@description('The tags to apply to the resources')
param tags object = {}

@description('The id of the log analytics workspace')
param logAnalyticsWorkspaceId string

@allowed(['web', 'other'])
param kind string = 'web'

@allowed(['Application_Type_web', 'Application_Type_other'])
param applicationType string = 'Application_Type_web'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: logAnalyticsWorkspaceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output id string = applicationInsights.id
output name string = applicationInsights.name
output connectionString string = applicationInsights.properties.ConnectionString
output instrumentationKey string = applicationInsights.properties.InstrumentationKey
