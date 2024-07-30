targetScope = 'subscription'

// parameters
param adminUserId string
param prefix string = ''
param location string = ''
param tags object = {}

// variables
var resourceGroupName = '${prefix}-rg'
var cosmosConnectionStringKey = 'cosmosconnectionstring'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module appInsights './appInsights.bicep' = {
  name: '${prefix}-appinsights'
  scope: rg
  params: {
    prefix: prefix
    tags: tags
  }
}

module storage './storage.bicep' = {
  name: '${prefix}-storage'
  scope: rg
  params: {
    storageAccountName: '${prefix}sa${uniqueString(resourceGroupName)}'
    accountType: 'Standard_LRS'
    kind: 'StorageV2'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: false
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    defaultOAuth: false
    accessTier: 'Cool'
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    networkAclsBypass: 'AzureServices'
    networkAclsDefaultAction: 'Allow'
    dnsEndpointType: 'Standard'
    largeFileSharesState: 'Enabled'
    keySource: 'Microsoft.Storage'
    encryptionEnabled: true
    infrastructureEncryptionEnabled: false
    isBlobSoftDeleteEnabled: true
    blobSoftDeleteRetentionDays: 7
    isContainerSoftDeleteEnabled: true
    containerSoftDeleteRetentionDays: 7
    isShareSoftDeleteEnabled: true
    shareSoftDeleteRetentionDays: 7
    tags: tags
  }
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

module user_identity_storage_container_roleassignment './user_identity_storage_container_roleassignment.bicep' = {
  name: '${prefix}-storage-roleassignment'
  scope: rg
  params: {
    storageAccountName: storage.outputs.storageAccountName
    storageAccountContributorDefinitionId: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
    principalId: user_identity.outputs.principalId
  }
}

module user_identity_storage_blob_roleassignment './user_identity_storage_blob_roleassignment.bicep' = {
  name: '${prefix}-storage-blob-roleassignment'
  scope: rg
  params: {
    storageAccountName: storage.outputs.storageAccountName
    storageBlobDataContributorDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
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

module keyvault './keyvault.bicep' = {
  name: '${prefix}keyvault'
  scope: rg
  params: {
    keyVaultName: 'ecoacakeyvault092899'
    tags: tags
    mangedIdentityId: user_identity.outputs.principalId
    adminUserId: adminUserId
    cosmosDbConnectionStringKey: cosmosConnectionStringKey
    cosmosDbConnectionString: cosmosdb.outputs.primaryConnectionString
  }
}

// THIS IMAGE WILL BE DEPLOYED FROM THE APPLICATION REPOSITORY
module aca_contextdiagram './aca_contextdiagram.bicep' = {
  name: '${prefix}-aca-contextdiagram'
  scope: rg
  params: {
    prefix: prefix
    workspaceId: aca_env.outputs.environmentId
    tags: tags
    identityId: user_identity.outputs.identityId
    // managedIdentityResourceId: resourceId(rg.name,'Microsoft.ManagedIdentity/userAssignedIdentities', user_identity.outputs.identityName)
    managedIdentityResourceId: '/subscriptions/494116cb-e794-4266-98e5-61c178d62cb4/resourcegroups/ecolab-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/ecolab-user-identity'
    azureContainerRegistry: acr.outputs.acrName
    userManagedIdentityId: user_identity.outputs.clientId
    keyVaultUrl: keyvault.outputs.keyVaultUri
    cosmosConnectionStringKey: cosmosConnectionStringKey
  }
}

// THIS IMAGE WILL BE DEPLOYED FROM THE APPLICATION REPOSITORY
// module aca_contextmapimage './aca_contextmapimage.bicep' = {
//   name: '${prefix}-aca-contextmapimage'
//   scope: rg
//   params: {
//     prefix: prefix
//     workspaceId: aca_env.outputs.environmentId
//     tags: tags
//     userManagedIdentityId: user_identity.outputs.clientId
//     azureContainerRegistry: acr.outputs.acrName
//   }
// }

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

// resource general outputs
output rgName string = rg.name
output storageAccountName string = storage.outputs.storageAccountName
output acrName string = acr.outputs.acrName
output keyVaultName string = keyvault.outputs.keyVaultName
output cosmosDbName string = cosmosdb.outputs.dbName

// App Insights outputs
output appInsightsId string = appInsights.outputs.appInsightsId
output appInsightsName string = appInsights.outputs.appInsightsName
output appInsightsInstrumentationKey string = appInsights.outputs.appInsightsInstrumentationKey
output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString

// Cosmos DB outputs
output cosmosContainerName string = cosmosdb.outputs.containerName
output cosmosDbEndpoint string = cosmosdb.outputs.endpoint
output cosmosPrimaryConnectionString string = cosmosdb.outputs.primaryConnectionString

// Key Vault outputs
output keyVaultId string = keyvault.outputs.keyVaultId
output keyVaultUri string = keyvault.outputs.keyVaultUri

// User Identity outputs
output userManagedIdentityId string = user_identity.outputs.clientId
output userManagedIdentityPrincipalId string = user_identity.outputs.principalId
output managedIdentityResourceId string = '/subscriptions/${subscription().id}/resourceGroups/${rg.name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${user_identity.name}'

