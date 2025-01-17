@description('Resource group location')
param location string = resourceGroup().location

@description('Name of the Log Analytics workspace')
param logAnalyticsWorkspaceName string = 'logAnalytics${uniqueString(resourceGroup().id)}'

@description('Name of the Key Vault')
param keyVaultName string = 'keyVault${uniqueString(resourceGroup().id)}'

@description('Name of the Storage Account')
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('Name of the Blob Container for Azure Function')
param blobContainerName string = 'fablob${uniqueString(resourceGroup().id)}'

@description('Name of the Function App')
param functionAppName string = 'functionApp${uniqueString(resourceGroup().id)}'

@description('Name of the User Managed Identity')
param userManagedIdentityName string = 'umi${uniqueString(resourceGroup().id)}'

@description('Name of the Cosmos DB Account')
param cosmosDbAccountName string = 'cosmosdb${uniqueString(resourceGroup().id)}'

@description('Expiration date for the secret in ISO 8601 format')
param secretExpiry string = dateTimeAdd(utcNow(), 'P60D')

@description('Name of the Cosmos DB Database')
param cosmosDbDatabaseName string = 'KvDatabase'

@description('Name of the Event Hub Namespace')
param eventHubNamespaceName string = 'kvEventHubNamespace'

@description('Name of the Event Hub')
param eventHubName string = 'kvEventHub'

var secretExpiryEpoch = dateTimeToEpoch(secretExpiry)

module userManagedIdentityModule 'modules/identity.bicep' = {
  name: 'userManagedIdentityModule'
  params: {
    userManagedIdentityName: userManagedIdentityName
    location: location
  }
}

module logAnalyticsModule 'modules/logAnalytics.bicep' = {
  name: 'logAnalyticsModule'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    location: location
  }
}

module policyModule 'modules/policies.bicep' = {
  name: 'policies'
  scope: subscription()
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsId
    identity: userManagedIdentityModule.outputs.userManagedIdentityId
    identityPrincipalId: userManagedIdentityModule.outputs.userManagedIdentityPrincipalId
  }
}

module cosmosDbModule 'modules/cosmosDb.bicep' = {
  name: 'cosmosDbModule'
  params: {
    cosmosDbAccountName: cosmosDbAccountName
    cosmosDbDatabaseName: cosmosDbDatabaseName
    userManagedIdentityPrincipalId: userManagedIdentityModule.outputs.userManagedIdentityPrincipalId
    location: location
  }
}

module functionAppModule 'modules/functionApp.bicep' = {
  name: 'functionAppModule'
  params: {
    functionAppName: functionAppName
    storageAccountName: storageAccountName
    blobContainerName: blobContainerName
    keyVaultName: keyVaultName
    userManagedIdentityName: userManagedIdentityName
    cosmosDbAccountEndpoint: cosmosDbModule.outputs.cosmosDbAccountEndpoint
    cosmosDbDatabaseName: cosmosDbDatabaseName
    cosmosDbSecretsContainerName: 'Secrets'
    eventHubName: eventHubName
    eventHubNamespaceName: eventHubNamespaceName
    location: location
  }
  dependsOn: [
    storageAccountModule
    eventHubModule
  ]
}

module keyVaultModule 'modules/keyVault.bicep' = {
  name: 'keyVaultModule'
  params: {
    keyVaultName: keyVaultName
    userManagedIdentityName: userManagedIdentityName
    secretExpiryEpoch: secretExpiryEpoch
    functionAppId: functionAppModule.outputs.functionAppId
    functionName: 'ProcessEventGridEvent'
    location: location
  }
  dependsOn: [
    policyModule
  ]
}

module storageAccountModule 'modules/storageAccount.bicep' = {
  name: 'storageAccountModule'
  params: {
    storageAccountName: storageAccountName
    blobContainerName: blobContainerName
    location: location
  }
}

module eventHubModule 'modules/eventHub.bicep' = {
  name: 'eventHubModule'
  params: {
    eventHubNamespaceName: eventHubNamespaceName
    eventHubName: eventHubName
    userManagedIdentityName: userManagedIdentityName
    location: location
  }
}
