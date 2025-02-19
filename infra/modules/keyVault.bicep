param keyVaultName string
param location string
param userManagedIdentityName string
param logAnalyticsId string
param currentDate string = utcNow()

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-PREVIEW' existing = {
  name: userManagedIdentityName
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: false
  }
}

resource keyVaultSecret1 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'testkey1'
  properties: {
    value: 'testvalue1'
    attributes: {
      exp: dateTimeToEpoch(dateTimeAdd(currentDate, 'P60D'))
    }
  }
}

resource keyVaultSecret2 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'testkey2'
  properties: {
    value: 'testvalue2'
    attributes: {
      exp: dateTimeToEpoch(dateTimeAdd(currentDate, 'P90D'))
    }
  }
}

resource keyVaultSecret3 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'testkey3'
  properties: {
    value: 'testvalue3'
    attributes: {
      exp: dateTimeToEpoch(dateTimeAdd(currentDate, 'P120D'))
    }
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, userManagedIdentity.id, '4633458b-17de-408a-b874-0445c86b69e6')
  scope: keyVault
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User role
    principalId: userManagedIdentity.properties.principalId
  }
}

resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'AuditLogs'
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
  }
}
