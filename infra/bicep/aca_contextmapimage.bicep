// Bicep: https://aka.ms/bicep

@description('Prefix for all resources')
param prefix string

@description('Azure Container Apps Workspace Id for the container app')
param workspaceId string

@description('Tags for all resources')
param tags object = {}

@description('User-assigned identity for the container app')
param identityId string

@description('Resource Id of Managed Identity')
param managedIdentityResourceId string

@description('Azure Container Registry for the container app')
param azureContainerRegistry string

@description('Keyvault Url')
param keyVaultUrl string

@description('Blob Storage Url Key')
param blobStorageUrlKey string

var contextMapImageSecretKey = 'contextmapimagesecret'

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: '${prefix}-contextmapimage'
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  tags: tags
  properties: {
    configuration: {
      ingress: {
        external: true
        targetPort: 5125
      }
      registries: [
        {
          server: '${azureContainerRegistry}.azurecr.io'
          identity: identityId
        }
      ]
      secrets: [
        {
            keyVaultUrl: '${keyVaultUrl}secrets/${blobStorageUrlKey}'
            identity: managedIdentityResourceId
            name: blobStorageUrlKey
        }
        {
            keyVaultUrl: '${keyVaultUrl}secrets/${contextMapImageSecretKey}'
            identity: managedIdentityResourceId
            name: contextMapImageSecretKey
        }
      ]
    }
    environmentId: workspaceId
    template: {
      containers: [
        {
          name: 'contextmapimage'
          image: '${azureContainerRegistry}.azurecr.io/contextmapimage:latest'
          env: [
            {
              name: 'BLOB_STORAGE_URL'
              secretRef: blobStorageUrlKey
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: '53765060-07f4-4acd-9caa-87268604a361'
            }
            {
              name: 'AZURE_TENANT_ID'
              value: '93366ed2-d3b1-450b-9a7a-97c613864bad'
            }
            {
              name: 'AZURE_CLIENT_SECRET'
              secretRef: contextMapImageSecretKey
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: 'InstrumentationKey=f9446849-e80d-4f3c-85bf-37633a6f3686;IngestionEndpoint=https://centralus-0.in.applicationinsights.azure.com/;LiveEndpoint=https://centralus.livediagnostics.monitor.azure.com/;ApplicationId=a89c130c-a790-47a3-9ff9-1b1587e97ba2'
            }
          ]
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
    }
  }
}
