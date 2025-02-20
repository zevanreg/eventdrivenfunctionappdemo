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

@description('Name of the User Managed Identity')
param userManagedIdentityName string = 'umi${uniqueString(resourceGroup().id)}'

@description('Name of the Cosmos DB Account')
param cosmosDbAccountName string = 'cosmosdb${uniqueString(resourceGroup().id)}'

@description('Name of the Cosmos DB Database')
param cosmosDbDatabaseName string = 'KvDatabase'

@description('Name of the Cosmos DB Secrets container')
param cosmosDbSecretsContainerName string = 'Secrets'

@description('Name of the Cosmos DB Workloads container')
param cosmosDbWorkloadsContainerName string = 'Workloads'

@description('Name of the Cosmos DB Config container')
param cosmosDbConfigContainerName string = 'Config'

@description('Name of the Cosmos DB container for secrets access events')
param cosmosDbSecretsAccessContainerName string = 'SecretsAccessedEvents'

@description('Name of the kvReader Function App')
param funcAppKvReaderName string = 'kvReader${uniqueString(resourceGroup().id)}'

@description('Name of the kvReader Function App')
param funcAppKvEventsListenerName string = 'kvEventsListener${uniqueString(resourceGroup().id)}'

@description('DOTNET or PS version of kvListener')
@allowed([
  'dotnet'
  'ps'
])
param kvEventsListenerRuntime string = 'dotnet'

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
    userManagedIdentityName: userManagedIdentityName
    location: location
  }
  dependsOn: [
    userManagedIdentityModule
  ]
}

module cosmosDbModule 'modules/cosmosDb.bicep' = {
  name: 'cosmosDbModule'
  params: {
    cosmosDbAccountName: cosmosDbAccountName
    cosmosDbDatabaseName: cosmosDbDatabaseName
    cosmosDbSecretsContainerName: cosmosDbSecretsContainerName
    cosmosDbSecretsAccessContainerName: cosmosDbSecretsAccessContainerName
    cosmosDbWorkloadsContainerName: cosmosDbWorkloadsContainerName
    cosmosDbConfigContainerName: cosmosDbConfigContainerName
    userManagedIdentityPrincipalId: userManagedIdentityModule.outputs.userManagedIdentityPrincipalId
    location: location
  }
}

module functionAppModule 'modules/functionApp.bicep' = {
  name: 'functionAppModule'
  params: {
    storageAccountName: storageAccountName
    keyVaultName: keyVaultName
    userManagedIdentityName: userManagedIdentityName
    cosmosDbAccountEndpoint: cosmosDbModule.outputs.cosmosDbAccountEndpoint
    cosmosDbDatabaseName: cosmosDbDatabaseName
    cosmosDbSecretsContainerName: cosmosDbSecretsContainerName
    cosmosDbSecretsAccessContainerName: cosmosDbSecretsAccessContainerName
    cosmosDbWorkloadsContainerName: cosmosDbWorkloadsContainerName
    cosmosDbConfigContainerName: cosmosDbConfigContainerName
    workspaceId: logAnalyticsModule.outputs.workspaceId
    kvReaderAppName: funcAppKvReaderName
    kvEventsListenerAppName: funcAppKvEventsListenerName
    kvEventsListenerRuntime: kvEventsListenerRuntime
    location: location
  }
  dependsOn: [
    storageAccountModule
  ]
}

module keyVaultModule 'modules/keyVault.bicep' = {
  name: 'keyVaultModule'
  params: {
    keyVaultName: keyVaultName
    userManagedIdentityName: userManagedIdentityName
    logAnalyticsId: logAnalyticsModule.outputs.logAnalyticsId
    location: location
  }
  dependsOn: [
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
