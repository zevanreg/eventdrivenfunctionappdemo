function Parse-AzureResourceId {
    param (
        [string]$resourceId
    ) 

    if ($resourceId -match "/subscriptions/(?<subscriptionId>[^/]+)/resourceGroups/(?<resourceGroupName>[^/]+)/providers/(?<provider>[^/]+)/(?<resourceType>[^/]+)/(?<resourceName>[^/]+)") {
        return @{
            SubscriptionId = $matches['subscriptionId']
            ResourceGroupName = $matches['resourceGroupName']
            VaultName = $matches['resourceName']
        }
    } else {
        throw "Invalid resource ID format"
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

function Parse-AppIdentityId {
    param (
        [string]$resourceId
    )

    if ($resourceId -match "/subscriptions/(?<subscriptionId>[^/]+)/resourceGroups/(?<resourceGroupName>[^/]+)/providers/(?<provider>[^/]+)/(?<resourceType>[^/]+)/(?<resourceName>[^/]+)") {
        return @{
            SubscriptionId = $matches['subscriptionId']
            ResourceGroupName = $matches['resourceGroupName']
            ResourceName = $matches['resourceName']
        }
    } else {
        throw "Invalid resource ID format"
    }
}

# Example usage
$resourceId = "/subscriptions/1e9bc235-6f50-42b5-ab2d-deeaded0884c/resourcegroups/kv-poc-1-rg/providers/Microsoft.Web/sites/secretreader"
$parsedResourceId = Parse-AzureResourceId -resourceId $resourceId

$parsedResourceId | Format-List

function Get-ExpiryDate {
    param (
        [int]$expiryTime
    )
    $dateTime = $null
    if ($null -ne $expiryTime) {
        $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
        $dateTime = $origin.AddSeconds($expiryTime)
    }
    return $dateTime
}



Export-ModuleMember -Function Parse-AzureResourceId, Parse-KeyVaultSecretUrl, Parse-AppIdentityId, Get-ExpiryDate