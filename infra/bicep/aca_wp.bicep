// Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces?pivots=deployment-language-bicep

@description('Prefix for all resources')
param prefix string

@description('Tags for all resources')
param tags object = {}

resource aca_workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${prefix}-aca-workspace'
  location: resourceGroup().location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      legacy: 0
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output workspaceId string = aca_workspace.properties.customerId
output workspaceName string = aca_workspace.name
