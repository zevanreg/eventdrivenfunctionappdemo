param logAnalyticsWorkspaceName string
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

// resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: 'AuditLogs'
//   scope: keyVault
//   properties: {
//     workspaceId: logAnalytics.id
//     logs: [
//       {
//         category: 'AuditEvent'
//         enabled: true
//         retentionPolicy: {
//           days: 0
//           enabled: false
//         }
//       }
//     ]
//   }
// }

output logAnalyticsId string = logAnalytics.id
