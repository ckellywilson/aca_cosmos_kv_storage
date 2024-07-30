// Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments?pivots=deployment-language-bicep
// Bicep Error: https://github.com/microsoft/azure-container-apps/issues/990

@description('Prefix for all resources')
param prefix string

@description('Tags for all resources')
param tags object = {}

@description('Log Analytics Workspace for the container app')
param logAnalyticsWorkspaceId string

@description('Log Analytics Shared Key for the container app')
param logAnalyticsWorkspaceName string

resource aca_workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource aca_env 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: '${prefix}-aca-env'
  location: resourceGroup().location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspaceId
        sharedKey: listKeys(aca_workspace.id, '2023-09-01').primarySharedKey
      }
    }
    zoneRedundant: false
    kedaConfiguration: {}
    daprConfiguration: {}
    customDomainConfiguration: {}
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
      }
    ]
    peerAuthentication: {
      mtls: {
        enabled: false
      }
    }
    peerTrafficConfiguration: {
      encryption: {
        enabled: false
      }
    }
  }
}

output environmentId string = aca_env.id
