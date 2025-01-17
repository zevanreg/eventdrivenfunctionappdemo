param eventHubNamespaceName string
param eventHubName string
param userManagedIdentityName string
param location string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 1
  }
  // properties: {
  //   isAutoInflateEnabled: true
  //   maximumThroughputUnits: 20
  // }
  resource eventHub 'eventHubs' = {
    name: eventHubName
    properties: {
      messageRetentionInDays: 1
      partitionCount: 2
    }
  }
}

var dataReceiverId = 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde'
var fullDataReceiverId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', dataReceiverId)
var eventHubRoleAssignmentName = '${resourceGroup().id}${eventHubName}${dataReceiverId}${eventHubNamespace::eventHub.name}'
var roleAssignmentName = guid(eventHubRoleAssignmentName, eventHubName, dataReceiverId)

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-PREVIEW' existing = {
  name: userManagedIdentityName
}

resource clusterEventHubAuthorization 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  //  See https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scope-extension-resources
  //  for scope for extension
  scope: eventHubNamespace::eventHub
  properties: {
    description: 'Give "Azure Event Hubs Data Receiver" to the cluster'
    principalId: userManagedIdentity.properties.principalId
    //  Required in case principal not ready when deploying the assignment
    principalType: 'ServicePrincipal'
    roleDefinitionId: fullDataReceiverId
  }
}

output eventHubNamespaceId string = eventHubNamespace.id
output eventHubId string = eventHubNamespace::eventHub.id
