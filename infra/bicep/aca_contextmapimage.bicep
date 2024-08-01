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

@description('Context Map Image Secret Key')
param contextMapImageSecretKey string

@description('Application Insights Connection String')
param appInsightsConnectionString string

@description('Azure Client Id')
param azureClientId string

@description('Azure Tenant Id')
param azureTenantId string

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
              value: azureClientId
            }
            {
              name: 'AZURE_TENANT_ID'
              value: azureTenantId
            }
            {
              name: 'AZURE_CLIENT_SECRET'
              secretRef: contextMapImageSecretKey
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: appInsightsConnectionString
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
