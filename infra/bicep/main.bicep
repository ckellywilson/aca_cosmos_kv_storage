targetScope = 'subscription'

// parameters
param prefix string=''
param location string = ''
param tags object = {}

// variables
var resourceGroupName = '${prefix}-rg'
var containerAppContextDiagram = '${prefix}-aca-contextdiagram'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module acr './acr.bicep' = {
  name: '${prefix}-acr'
  scope: rg
  params: {
    location: location
    tags: tags
  }
}

module user_identity './user_identity.bicep' = {
  name: '${prefix}-identity'
  scope: rg
  params: {
    prefix: prefix
    tags: tags
  }
}

module user_identity_acr_roleassignment './user_identity_acr_roleassignment.bicep' = {
  name: '${prefix}-acr-roleassignment'
  scope: rg
  params: {
    azureContainerRegistry: acr.outputs.acrName
    acrPullDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    principalId: user_identity.outputs.principalId
  }
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

module aca_contextdiagram './aca_contextdiagram.bicep' = {
  name: containerAppContextDiagram
  scope: rg
  params: {
    prefix: prefix
    workspaceId: aca_env.outputs.environmentId
    tags: tags
    identityId: user_identity.outputs.identityId
    azureContainerRegistry: acr.outputs.acrName
  }
}

module cosmosdb './cosmosdb.bicep' = {
  name: '${prefix}-cosmosdb'
  scope: rg
  params: {
    prefix: prefix
    tags: tags
    location: location
    databaseName: 'Context'
    containerName: 'ContextDiagram'
  }
}
