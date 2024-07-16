@description('Azure Container Registry Name')
param storageAccountName string

@description('Azure Container Registry Pull Role Definition Id')
param storageAccountContributorDefinitionId string

@description('Principal Id of the user-assigned identity')
param principalId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, storageAccountName, 'StorageAccountContributorUserAssigned')
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    // StorageAccountContributor has a value of 17d1049b-9a84-46fb-8f53-869881c3d3ab
    // https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageAccountContributorDefinitionId)
  }
}
