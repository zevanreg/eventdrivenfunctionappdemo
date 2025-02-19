param cosmosDbAccountName string
param cosmosDbDatabaseName string
param cosmosDbSecretsContainerName string
param cosmosDbSecretsAccessContainerName string
param cosmosDbWorkloadsContainerName string
param cosmosDbConfigContainerName string
param userManagedIdentityPrincipalId string
param location string

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-03-15' = {
  name: cosmosDbAccountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    enableFreeTier: true
  }
}

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-03-15' = {
  parent: cosmosDbAccount
  name: cosmosDbDatabaseName
  properties: {
    resource: {
      id: cosmosDbDatabaseName
    }
  }
}

resource cosmosDbContainerSecrets 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-03-15' = {
  parent: cosmosDbDatabase
  name: cosmosDbSecretsContainerName
  properties: {
    resource: {
      id: cosmosDbSecretsContainerName
      partitionKey: {
        paths: ['/akvName']
        kind: 'Hash'
      }
    }
  }
}

resource cosmosDbContainerWorkloads 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-03-15' = {
  parent: cosmosDbDatabase
  name: cosmosDbWorkloadsContainerName
  properties: {
    resource: {
      id: cosmosDbWorkloadsContainerName
      partitionKey: {
        paths: ['/subscriptionID']
        kind: 'Hash'
      }
    }
  }
}

resource cosmosDbContainerSecretAccess 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-03-15' = {
  parent: cosmosDbDatabase
  name: cosmosDbSecretsAccessContainerName
  properties: {
    resource: {
      id: cosmosDbSecretsAccessContainerName
      partitionKey: {
        paths: ['/objectID']
        kind: 'Hash'
      }
    }
  }
}

resource cosmosDbContainerConfig 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-03-15' = {
  parent: cosmosDbDatabase
  name: cosmosDbConfigContainerName
  properties: {
    resource: {
      id: cosmosDbConfigContainerName
      partitionKey: {
        paths: ['/id']
        kind: 'Hash'
      }
    }
  }
}

var roleDefinitionId = '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.DocumentDB/databaseAccounts/${cosmosDbAccountName}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002'

resource cosmosDBRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-10-15' = {
  name: guid(roleDefinitionId, userManagedIdentityPrincipalId, cosmosDbAccount.id)
  parent: cosmosDbAccount
  properties: {
    principalId: userManagedIdentityPrincipalId
    roleDefinitionId: roleDefinitionId
    scope: cosmosDbAccount.id
  }
}


output cosmosDbAccountEndpoint string = cosmosDbAccount.properties.documentEndpoint
