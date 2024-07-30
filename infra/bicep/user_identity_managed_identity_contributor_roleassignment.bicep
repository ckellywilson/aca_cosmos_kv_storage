

@description('User-Assigned managed identity name')
param managedIdentityName string

@description('Azure Container Registry Pull Role Definition Id')
param managedIdentityContributorDefinitionId string

@description('Logged-in user Principal Id')
param principalId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, managedIdentityName, 'StorageAccountContributorUserAssigned')
  properties: {
    principalId: principalId
    principalType: 'User'
    // ManagedIdentityContributor has a value of e40ec5ca-96e0-45a2-b4ff-59039f2c2b59
    // https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#identity
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', managedIdentityContributorDefinitionId)
  }
}
