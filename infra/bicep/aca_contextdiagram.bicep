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

@description('User Manged Identity Id')
param userManagedIdentityId string

@description('Azure Container Registry for the container app')
param azureContainerRegistry string

@description('Keyvault Url')
param keyVaultUrl string

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
            keyVaultUrl: 'https://ecoacakeyvault092899.vault.azure.net/secrets/cosmosconnectionstring'
            identity: managedIdentityResourceId 
            name: 'cosmosconnectionstring'
            // value: 'AccountEndpoint=https://ecolab-cosmos.documents.azure.com:443/;AccountKey=It6l6iaCaolrMGHetcehYcvEDLnhTV35BizEWCe22UVBKInUw9setdme8tNzkv8JUqUu7bVudiR9ACDb3cpVUg==;'
        }
      ]
    }
    environmentId: workspaceId
    template: {
      containers: [
        {
          name: 'contextdiagram'
          image: '${azureContainerRegistry}.azurecr.io/contextdiagram:latest'
          env: [
            {
              name: 'COSMOS_CONNECTION_STRING'
              secretRef: 'cosmosconnectionstring'
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
