@description('Azure Container Registry Name')
param storageAccountName string

@description('Azure Container Registry Pull Role Definition Id')
param storageBlobDataContributorDefinitionId string

@description('Principal Id of the user-assigned identity')
param principalId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, storageAccountName, 'StorageBlobDataContributorUserAssigned')
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    // Storage Blob Data Contributor has a value of ba92f5b4-2d11-453d-a403-e96b0029c9fe
    // https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorDefinitionId)
  }
}
