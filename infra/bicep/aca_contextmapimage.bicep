// Bicep: https://aka.ms/bicep

@description('Prefix for all resources')
param prefix string

@description('Azure Container Apps Workspace Id for the container app')
param workspaceId string

@description('Tags for all resources')
param tags object = {}

@description('Resource Id of Managed Identity')
param managedIdentityResourceId string

@description('Azure Container Registry for the container app')
param azureContainerRegistry string

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: '${prefix}-contextmapimage'
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userManagedIdentityId}': {}
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
          identity: userManagedIdentityId
        }
      ]
      secrets: [
        {
            keyVaultUrl: '${keyVaultUrl}secrets/${cosmosConnectionStringKey}'
            identity: managedIdentityResourceId
            name: 'azure-client-secret'
        }]
    }
    environmentId: workspaceId
    template: {
      containers: [
        {
          name: 'contextmapimage'
          image: '<your-image>'
          env: [
            {
              name: 'BLOB_STORAGE_URL'
              value: '<your-blob-storage-url>'
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: '<your-client-id>'
            }
            {
              name: 'AZURE_TENANT_ID'
              value: '<your-tenant-id>'
            }
            {
              name: 'AZURE_CLIENT_SECRET'
              secretRef: 'azure-client-secret'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: '<your-app-insights-connection-string>'
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
