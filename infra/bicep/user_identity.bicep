// Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.managedidentity/userassignedidentities?pivots=deployment-language-bicep

param prefix string
param tags object = {}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: '${prefix}-user-identity'
  location: resourceGroup().location 
  tags: tags
}

output identityName = identity.name
output principalId string = identity.properties.principalId
output clientId string = identity.properties.clientId
output identityId string = identity.id
