targetScope = 'subscription'

// parameters
param prefix string=''
param location string = ''
param tags object = {}

// variables
var resourceGroupName = '${prefix}-rg'
var containerAppName = '${prefix}-aca'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module aca_wp './aca_wp.bicep' = {
  name: '${prefix}-aca-wp'
  scope: rg
  params: {
    prefix: prefix
    tags: tags
  }
}

module aca_env './aca_env.bicep' = {
  name: '${prefix}-aca-env'
  scope: rg
  params: {
    prefix: prefix
    tags: tags
    logAnalyticsWorkspaceId: aca_wp.outputs.workspaceId
    logAnalyticsSharedKey: aca_wp.outputs.workspaceKey
  }
}

module aca './aca.bicep' = {
  name: containerAppName
  scope: rg
  params: {
    prefix: prefix
    workspaceId: aca_env.outputs.environmentId
    tags: tags
  }
}

module cosmosdb './aca_cosmosdb.bicep' = {
  name: '${prefix}-cosmosdb'
  scope: rg
  params: {
    prefix: prefix
    tags: tags
    location: location
  }
}
