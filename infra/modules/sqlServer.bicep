// resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
//   name: 'vikkzlsqlserver'
//   location: location
//   properties: {
//     administrators: {
//       administratorType: 'ActiveDirectory'
//       azureADOnlyAuthentication: true
//       login: 'viktoras.kozlovskis_gmail.com#EXT#@viktoraskozlovskisgmail.onmicrosoft.com'
//       principalType: 'User'
//       sid: '571f32e0-c221-44ac-8a20-e5406ddddbf2'
//       tenantId: subscription().tenantId
//     }
//     minimalTlsVersion: '1.2'
//     publicNetworkAccess: 'Enabled'
//   }
//   identity: {
//     type: 'SystemAssigned'
//   }
// }

// resource sqlServerAdmin 'Microsoft.Sql/servers/administrators@2023-05-01-preview' = {
//   name: 'ActiveDirectory'
//   parent: sqlServer
//   properties: {
//     administratorType: 'ActiveDirectory'
//     login: 'viktoras.kozlovskis_gmail.com#EXT#@viktoraskozlovskisgmail.onmicrosoft.com'
//     sid: '571f32e0-c221-44ac-8a20-e5406ddddbf2'
//     tenantId: subscription().tenantId
//   }
// }

// resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
//   name: 'KeyVaults'
//   parent: sqlServer
//   properties: {
//     collation: 'SQL_Latin1_General_CP1_CI_AS'
//     maxSizeBytes: 33554432 // 2 GB
//   }
//   sku: {
//     name: 'Free'
//     tier: 'Free'
//   }
//   location: location
// }
