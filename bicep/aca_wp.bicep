// Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces?pivots=deployment-language-bicep

@description('Prefix for all resources')
param prefix string

resource aca_workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${prefix}-aca-workspace'
  location: resourceGroup().location
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
output workspaceKey string =  listKeys(aca_workspace.id, '2023-09-01').primarySharedKey
