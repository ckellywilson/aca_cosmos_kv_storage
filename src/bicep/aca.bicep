// Bicep: https://aka.ms/bicep

@description('Prefix for all resources')
param prefix string

@description('Azure Container Apps Workspace Id for the container app')
param workspaceId string

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: '${prefix}-containerapp'
  location: resourceGroup().location
  properties: {
    configuration: {
      ingress: {
        external: true
        targetPort: 80
      }
    }
    environmentId: workspaceId
    template: {
      containers: [
        {
          name: 'helloworld'
          image: 'mcr.microsoft.com/k8se/quickstart:latest'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
    }
  }
}
