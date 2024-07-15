param prefix string
param tags object = {}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: '${prefix}-user-identity'
  location: resourceGroup().location 
  tags: tags
}

output principalId string = identity.properties.principalId
output identityId string = identity.id
