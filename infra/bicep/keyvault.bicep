// BICEP: https://learn.microsoft.com/en-us/azure/key-vault/secrets/quick-create-bicep?tabs=CLI

targetScope = 'resourceGroup'

param keyVaultName string
param mangedIdentityId string
param adminUserId string
param tags object = {}

@description('Name of the CosmosDB Connection string key')
param cosmosDbConnectionStringKey string

@description('Value of the CosmosDB Connection string key')
@secure()
param cosmosDbConnectionString string

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
          secrets: ['all']
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
	value: cosmosDbConnectionString
  }
}

output keyVaultId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri
output keyVaultName string = keyVault.name
