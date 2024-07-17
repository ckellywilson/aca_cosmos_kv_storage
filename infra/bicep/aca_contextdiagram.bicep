// Bicep: https://aka.ms/bicep

@description('Prefix for all resources')
param prefix string

@description('Azure Container Apps Workspace Id for the container app')
param workspaceId string

@description('Tags for all resources')
param tags object = {}

@description('User-assigned identity for the container app')
param identityId string

@description('User Manged Identity Id')
param userManagedIdentityId string

@description('Azure Container Registry for the container app')
param azureContainerRegistry string

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: '${prefix}-contextdiagram'
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
        targetPort: 5081
      }
      registries: [
        {
          server: '${azureContainerRegistry}.azurecr.io'
          identity: identityId
        }
      ]
      secrets: [
        {
          name: 'cosmosconnectionstring'
          value: '<your-cosmos-connection-string>'
        }
      ]
    }
    environmentId: workspaceId
    template: {
      containers: [
        {
          name: 'contextdiagram'
          image: '<your-image>'
          env: [
            {
              name: 'COSMOS_CONNECTION_STRING'
              secretRef: 'cosmosconnectionstring'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: '<your-application-insights-connection-string>'
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
