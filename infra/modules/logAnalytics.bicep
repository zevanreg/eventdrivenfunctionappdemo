param logAnalyticsWorkspaceName string
param userManagedIdentityName string
param location string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  sku: {
    name: 'PerGB2018'
  }
  properties: {
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-PREVIEW' existing = {
  name: userManagedIdentityName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, logAnalytics.id, userManagedIdentity.id, '73c42c96-874c-492b-b04d-ab87d138a893') // Log Analytics Reader role ID
  scope: logAnalytics
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/73c42c96-874c-492b-b04d-ab87d138a893' // Log Analytics Reader role ID
    principalId: userManagedIdentity.properties.principalId
  }
}

output logAnalyticsId string = logAnalytics.id
output workspaceId string = logAnalytics.properties.customerId
