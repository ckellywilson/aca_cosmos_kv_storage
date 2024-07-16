// Bicep: https://aka.ms/bicep

@description('Prefix for all resources')
param prefix string

@description('Azure Container Apps Workspace Id for the container app')
param workspaceId string

@description('Tags for all resources')
param tags object = {}

@description('User-assigned identity for the container app')
param identityId string

@description('Azure Container Registry for the container app')
param azureContainerRegistry string

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
            name: 'azure-client-secret'
            value: 'NhZ8Q~FOxue5PD3Z2RWcr3xUSIa0l4JwQGolYdp8'
        }]
    }
    environmentId: workspaceId
    template: {
      containers: [
        {
          name: 'contextmapimage'
          image: 'acr4eemppzyag4po.azurecr.io/contextmapimage:latest'
          env: [
            {
              name: 'BLOB_STORAGE_URL'
              value: 'https://ecolabacasa.blob.core.windows.net'
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: 'd119f74e-d4ca-4267-bf89-03ef71c84e12'
            }
            {
              name: 'AZURE_TENANT_ID'
              value: '93366ed2-d3b1-450b-9a7a-97c613864bad'
            }
            {
              name: 'AZURE_CLIENT_SECRET'
              secretRef: 'azure-client-secret'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: 'InstrumentationKey=8473fbb9-1de0-4a50-91b2-79b2ace42063;IngestionEndpoint=https://centralus-3.in.applicationinsights.azure.com/;LiveEndpoint=https://centralus.livediagnostics.monitor.azure.com/;ApplicationId=3f480e9d-6f66-481d-b9d7-627ff8161994'
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
