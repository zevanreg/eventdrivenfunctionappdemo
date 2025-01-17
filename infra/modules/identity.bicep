param userManagedIdentityName string
param location string

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-PREVIEW' = {
  name: userManagedIdentityName
  location: location
}

output userManagedIdentityId string = userManagedIdentity.id
output userManagedIdentityPrincipalId string = userManagedIdentity.properties.principalId
