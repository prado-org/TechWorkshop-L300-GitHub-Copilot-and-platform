@description('The name of the log analytics workspace')
param name string

@description('The location into which the resources should be deployed')
param location string = resourceGroup().location

@description('The tags to apply to the resources')
param tags object = {}

@description('The workspace data retention in days, between 30 and 730')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('The workspace daily quota for ingestion in GB, -1 for unlimited')
param dailyQuotaGb int = -1

@allowed(['CapacityReservation', 'Free', 'LACluster', 'PerGB2018', 'PerNode', 'Premium', 'Standalone', 'Standard'])
param skuName string = 'PerGB2018'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    retentionInDays: retentionInDays
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    sku: {
      name: skuName
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output id string = logAnalytics.id
output name string = logAnalytics.name
output customerId string = logAnalytics.properties.customerId
