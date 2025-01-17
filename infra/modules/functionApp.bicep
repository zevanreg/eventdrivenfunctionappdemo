param location string
param functionAppName string
param storageAccountName string
param keyVaultName string
param userManagedIdentityName string
param blobContainerName string
param cosmosDbAccountEndpoint string
param cosmosDbDatabaseName string
param cosmosDbSecretsContainerName string
param eventHubNamespaceName string
param eventHubName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-PREVIEW' existing = {
  name: userManagedIdentityName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'consumptionPlan'
  location: location
  sku: {
    name: 'FC1'
    tier: 'FlexConsumption'
  }
  kind: 'linux'
  properties: {
    reserved: true
    zoneRedundant: false
  }
}

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'testkey'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/testkey/)'
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
          name: 'eventHubName'
          value: eventHubName
        }
        {
          name: 'eventhub__fullyQualifiedNamespace'
          value: '${eventHubNamespaceName}.servicebus.windows.net'
        }
        {
          name: 'eventhub__credential'
          value: 'managedidentity'
        }
        {
          name: 'eventhub__clientId'
          value: userManagedIdentity.properties.clientId
        }
        // {
        //   name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        //   value: applicationInsights.properties.InstrumentationKey
        // }
      ]
    }
    keyVaultReferenceIdentity: userManagedIdentity.id
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storageAccount.properties.primaryEndpoints.blob}${blobContainerName}'
          authentication: {
            type: 'StorageAccountConnectionString'
            storageAccountConnectionStringName: 'AzureWebJobsStorage'
          }
        }
      }
      scaleAndConcurrency: {
        maximumInstanceCount: 100
        instanceMemoryMB: 2048
      }
      runtime: {
        name: 'powershell'
        version: '7.4'
      }

    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userManagedIdentity.id}': {}
    }
  }
}



// resource sqlConnectionString 'Microsoft.Web/sites/config@2020-12-01' = {
//   parent: functionApp
//   name: 'connectionstrings'
//   properties: {
//     DefaultConnection: {
//       value: 'Server=tcp:vikkzlsqlserver.database.windows.net,1433;Initial Catalog=${sqlDatabase.name};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication="Active Directory Default";'
//       type: 'SQLAzure'
//     }
//   }
// }

output functionAppId string = functionApp.id
