@description('Azure Container Registry Name')
param azureContainerRegistry string

@description('Azure Container Registry Pull Role Definition Id')
param acrPullDefinitionId string

@description('Principal Id of the user-assigned identity')
param principalId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, azureContainerRegistry, 'AcrPullUserAssigned')
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    // acrPullDefinitionId has a value of 7f951dda-4ed3-4680-a7ca-43fe172d538d
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', acrPullDefinitionId)
  }
}
