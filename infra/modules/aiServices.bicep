@description('The name of the cognitive services resource')
param name string

@description('The location into which the resources should be deployed')
param location string = resourceGroup().location

@description('The tags to apply to the resources')
param tags object = {}

@allowed(['S0', 'S1', 'S2', 'S3', 'S4', 'F0'])
param sku string = 'S0'

resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  kind: 'OpenAI'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
    customSubDomainName: name
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
  sku: {
    name: sku
  }
}

// GPT-4 deployment
// resource gpt4Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
//   parent: cognitiveServices
//   name: 'gpt'
//   properties: {
//     model: {
//       format: 'OpenAI'
//       name: 'gpt-5.2'
//       //version: '0613'
//     }
//     versionUpgradeOption: 'OnceCurrentVersionExpired'
//     //currentCapacity: 10
//     raiPolicyName: 'Microsoft.DefaultV2'
//   }
// }

// GPT-4 Turbo deployment
// resource gpt4TurboDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
//   parent: cognitiveServices
//   name: 'gpt-4-turbo'
//   properties: {
//     model: {
//       format: 'OpenAI'
//       name: 'gpt-4'
//       version: '1106-Preview'
//     }
//     versionUpgradeOption: 'OnceCurrentVersionExpired'
//     currentCapacity: 10
//     raiPolicyName: 'Microsoft.DefaultV2'
//   }
//   dependsOn: [gpt4Deployment]
// }

// Text Embedding deployment
// resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
//   parent: cognitiveServices
//   name: 'text-embedding-ada-002'
//   properties: {
//     model: {
//       format: 'OpenAI'
//       name: 'text-embedding-ada-002'
//       version: '2'
//     }
//     versionUpgradeOption: 'OnceCurrentVersionExpired'
//     currentCapacity: 10
//     raiPolicyName: 'Microsoft.DefaultV2'
//   }
//   dependsOn: [gpt4TurboDeployment]
// }

output id string = cognitiveServices.id
output name string = cognitiveServices.name
output endpoint string = cognitiveServices.properties.endpoint
output host string = split(cognitiveServices.properties.endpoint, '/')[2]
