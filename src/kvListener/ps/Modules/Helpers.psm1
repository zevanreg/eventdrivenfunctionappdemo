function Parse-AzureResourceId {
    param (
        [string]$resourceId
    ) 

    if ($resourceId -match "/subscriptions/(?<subscriptionId>[^/]+)/resourceGroups/(?<resourceGroupName>[^/]+)/providers/(?<provider>[^/]+)/(?<resourceType>[^/]+)/(?<resourceName>[^/]+)") {
        return @{
            SubscriptionId = $matches['subscriptionId']
            ResourceGroupName = $matches['resourceGroupName']
            Provider = $matches['provider']
            ResourceType = $matches['resourceType']
            ResourceName = $matches['resourceName']
        }
    } else {
        Write-Warning "Invalid resource ID format"
        return $null
    }
}

function Parse-KeyVaultSecretUrl {
    param (
        [string]$secretUrl
    )

    if ($secretUrl -match "https://[^/]+/secrets/(?<secretName>[^/]+)") {
        return $matches['secretName']
    } else {
        throw "Invalid Key Vault secret URL format"
    }
}


Export-ModuleMember -Function Parse-AzureResourceId, Parse-KeyVaultSecretUrl