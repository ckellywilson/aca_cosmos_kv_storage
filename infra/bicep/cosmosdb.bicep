// Bicep: https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/manage-with-bicep#azure-cosmos-db-container-with-server-side-functionality

@description('Prefix for all resources')
param prefix string = ''

@description('Location for all resources')
@allowed([
  'eastus'
  'centralus'
])
param location string

@description('Name of the database')
param databaseName string

@description('Name of the container')
param containerName string

@description('Tags for all resources')
param tags object = {}

resource account 'Microsoft.DocumentDb/databaseAccounts@2024-05-15-preview' = {
  kind: 'GlobalDocumentDB'
  name: '${prefix}-cosmos'
  location: location
  tags:tags
  properties:{
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        failoverPriority: 0
        locationName: location
      }
    ]
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Local'
      }
    }
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    minimalTlsVersion: 'Tls12'
    capacityMode: 'Serverless'
    enableFreeTier: false
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-05-15' = {
  parent: account
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-05-15' = {
  parent: database
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
    }
  }
}

output endpoint string = account.properties.documentEndpoint
output dbName string = database.name
output containerName string = container.name
output accountName string = account.name
