param logAnalyticsWorkspaceId string
param location string
param identity string
param identityPrincipalId string

var policyDefinitionId = '/providers/Microsoft.Authorization/policyDefinitions/951af2fa-529b-416e-ab6e-066fd85ac459'
targetScope = 'subscription'

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'deploy-configure-diagnostic-settings-keyvault'
  location: location
  properties: {
    displayName: 'Deploy - Configure diagnostic settings for Azure Key Vault to Log Analytics workspace'
    policyDefinitionId: policyDefinitionId
    parameters: {
      logAnalytics: {
        value: logAnalyticsWorkspaceId
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity}': {}
    }
  }
}

// resource rMCassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid('Monitoring Contributor', subscription().id)
//   properties: {
//     principalId: identityPrincipalId
//     roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
//   }
// }

// resource rLACassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid('Log Analytics Contributor', subscription().id)
//   properties: {
//     principalId: identityPrincipalId
//     roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
//   }
// }

// resource remediateTask 'Microsoft.PolicyInsights/remediations@2024-10-01' = {
//   name: guid('Remediate', policyDefinitionId, subscription().id)
//   properties: {
//     failureThreshold: {
//       percentage: 1
//     }
//     resourceCount: 500
//     policyAssignmentId: policyAssignment.id
//     policyDefinitionReferenceId: policyDefinitionId
//     parallelDeployments: 10
//     resourceDiscoveryMode: 'ReEvaluateCompliance'
//   }
//   dependsOn: [
//     rLACassignment
//     rMCassignment
//   ]
// }
