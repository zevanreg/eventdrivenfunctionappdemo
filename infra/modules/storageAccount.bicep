param storageAccountName string
param blobContainerName string
param location string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowSharedKeyAccess: true
    publicNetworkAccess: 'Enabled'
    allowBlobPublicAccess: true
    // networkAcls: {
    //   defaultAction: 'Allow'
    // }
  }

  resource blobServices 'blobServices' = {
    name: 'default'
    properties: {
      deleteRetentionPolicy: {
        enabled: false
      }
    }
    resource container 'containers' = {
      name: blobContainerName
      properties: {
        publicAccess:'Container'
      }
    }
  }
}

// resource storageTable 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-05-01' = {
//   name: '${storageAccount.name}/default/secrets'
//   properties: {}
// }

// resource storageTableRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(storageAccount.id, userManagedIdentity.id, '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
//   scope: storageAccount
//   properties: {
//     roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3' // Storage Table Data Contributor role
//     principalId: userManagedIdentity.properties.principalId
//   }
// }

