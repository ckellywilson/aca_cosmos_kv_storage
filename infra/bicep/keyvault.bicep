// BICEP: https://learn.microsoft.com/en-us/azure/key-vault/secrets/quick-create-bicep?tabs=CLI

targetScope = 'resourceGroup'

param keyVaultName string
param mangedIdentityId string
param adminUserId string
param tags object = {}

@description('Name of the CosmosDB Connection string key')
param cosmosDbConnectionStringKey string

@description('Name of the CosmosDB account instance')
param cosmosDbAccountName string

@description('Name of the Blob Store Url Key')
param blobStorageUrlKey string

@description('Name of the storage account')
param storageAccountName string

resource account 'Microsoft.DocumentDb/databaseAccounts@2024-05-15-preview' existing = {
  name: cosmosDbAccountName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: resourceGroup().location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        objectId: adminUserId
        tenantId: subscription().tenantId
        permissions: {
          keys: ['all']
          secrets: ['all','purge']
          certificates: ['all']
        }
      }
      {
        objectId: mangedIdentityId
        tenantId: subscription().tenantId
        permissions: {
          keys: ['all']
          secrets: ['all']
          certificates: ['all']
        }
      }
    ]
  }
}

resource cosmosDbConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: cosmosDbConnectionStringKey
  properties: {
	value: account.listConnectionStrings().connectionStrings[0].connectionString
  }
}

resource blogStorageUrlSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: blobStorageUrlKey
  properties: {
	value: storageAccount.properties.primaryEndpoints.blob
  }
}

output keyVaultId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri
output keyVaultName string = keyVault.name
