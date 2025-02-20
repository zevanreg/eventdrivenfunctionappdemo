param location string
param storageAccountName string
param keyVaultName string
param userManagedIdentityName string
param cosmosDbAccountEndpoint string
param cosmosDbDatabaseName string
param cosmosDbSecretsContainerName string
param cosmosDbSecretsAccessContainerName string
param cosmosDbWorkloadsContainerName string
param cosmosDbConfigContainerName string
param workspaceId string
param kvReaderAppName string
param kvEventsListenerAppName string
@allowed([
  'dotnet'
  'ps'
])
param kvEventsListenerRuntime string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-PREVIEW' existing = {
  name: userManagedIdentityName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'appServicePlan'
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
    family: 'S'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
    zoneRedundant: false
  }
}

resource functionAppListener 'Microsoft.Web/sites@2024-04-01' = {
  name: kvEventsListenerAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    reserved: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: (kvEventsListenerRuntime == 'dotnet' ? 'DOTNET-ISOLATED|9.0' : 'PowerShell|7.4')
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: (kvEventsListenerRuntime == 'dotnet') ? 'dotnet-isolated' : 'powershell'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'AZURE_CLIENT_ID'
          value: userManagedIdentity.properties.clientId
        }
        {
          name: 'cosmosdb__accountEndpoint'
          value: cosmosDbAccountEndpoint
        }
        {
          name: 'cosmosdb__credential'
          value: 'managedidentity'
        }
        {
          name: 'cosmosdb__clientId'
          value: userManagedIdentity.properties.clientId
        }
        {
          name: 'cosmosDatabaseName'
          value: cosmosDbDatabaseName
        }
        {
          name: 'cosmosSecretsContainerName'
          value: cosmosDbSecretsContainerName
        }
        {
          name: 'cosmosSecretsAccessContainerName'
          value: cosmosDbSecretsAccessContainerName
        }
        {
          name: 'cosmosWorkloadsContainerName'
          value: cosmosDbWorkloadsContainerName
        }
        {
          name: 'cosmosConfigContainerName'
          value: cosmosDbConfigContainerName
        }
        {
          name: 'keyVaultName'
          value: keyVaultName
        }
        {
          name: 'workspaceId'
          value: workspaceId
        }
        {
          name: 'functionAppResourceId'
          value: resourceId('Microsoft.Web/sites', kvEventsListenerAppName)
        }        
      ]      
    }
    keyVaultReferenceIdentity: userManagedIdentity.id
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userManagedIdentity.id}': {}
    }
  }
}

resource functionAppReader 'Microsoft.Web/sites@2024-04-01' = {
  name: kvReaderAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    reserved: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNET-ISOLATED|9.0'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'AZURE_CLIENT_ID'
          value: userManagedIdentity.properties.clientId
        }
        {
          name: 'keyVaultName'
          value: keyVaultName
        }
        {
          name: 'testkey1'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/testkey1/)'
        }
        {
          name: 'testkey2'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/testkey2/)'
        }
        {
          name: 'testkey3'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/testkey3/)'
        }
      ]
    }
    keyVaultReferenceIdentity: userManagedIdentity.id
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userManagedIdentity.id}': {}
    }
  }
}

output functionAppId string = functionAppListener.id
