@description('Prefix for all resources')
param prefix string = ''

@description('Location for all resources')
@allowed([
  'eastus'
  'centralus'
])
param location string

@description('Tags for all resources')
param tags object = {}

resource cosmosDbAccount 'Microsoft.DocumentDb/databaseAccounts@2024-05-15-preview' = {
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
