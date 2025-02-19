# Input bindings are passed in via param block.
param($Timer, $ConfigIn)

$lastAccessed = @{
    id = $ConfigIn[0].id
    eventDate = $ConfigIn[0].eventDate
}

# Define the Kusto query
$query = @"
AzureDiagnostics
| where TimeGenerated > datetime('$($lastAccessed.eventDate)') and ResourceProvider == 'MICROSOFT.KEYVAULT' and Resource =~ '$env:keyVaultName' and OperationName == 'SecretGet' and Category == 'AuditEvent' and identity_claim_xms_az_rid_s != '' and identity_claim_xms_az_rid_s !~ '$env:functionAppResourceId'
| extend requestUri_base = strcat_array(array_slice(split(requestUri_s, '/'), 0, -2), '/')
| summarize arg_max(TimeGenerated, *) by identity_claim_xms_az_rid_s, requestUri_base
| project SubscriptionId, ResourceGroup, AppResourceId = identity_claim_xms_az_rid_s, CertificateUri = requestUri_base, KeyvaultName = Resource, KeyVaultResourceId = ResourceId, AppType = identity_claim_idtyp_s, TimeGenerated
"@

# Make a Kusto query to get CertificateGet events
$queryResults = Invoke-AzOperationalInsightsQuery -WorkspaceId $env:workspaceId -Query $query

$secrets = @()
$accessEvents = @()
$workloads += @()
# Iterate results
foreach ($record in $queryResults.Results) {
    # Parse CertificateUri to get the certificate name
    $secretUri = $record.CertificateUri
    $regex = [regex]::new("https://[^/]+/secrets/([^/?]+)")
    $result = $regex.Match($secretUri)
    $secretName = $result.Groups[1].Value

    # Get the secret from Key Vault
    $secret = Get-AzKeyVaultSecret -VaultName $record.KeyvaultName -Name $secretName

    if ($null -eq $secret)
    {
        Write-Host "Secret not found: $secretName"
        continue
    }

    # Extract the expiration date
    $expirationDate = $secret.Attributes.Expires

    $appResourceId = $record.AppResourceId -replace '/', '_'

    $secrets += @{ 
        id = $record.CertificateUri -replace '/', '_'
        akvName = $record.KeyvaultName
        secretName = $secretName
        expiryDate = $expirationDate
    }

    $accessEvents += @{ 
        id = $appResourceId + '_' + $record.KeyvaultName + '_' + $secretName
        objectId = $appResourceId
        akvName = $record.KeyvaultName
        secretName = $secretName
        lastAccessed = $record.TimeGenerated
        subscriptionId = $record.SubscriptionId
        resourceGroup = $record.ResourceGroup
    }

    $match = [regex]::Match($record.AppResourceId, "/subscriptions/(?<subscriptionId>[^/]+)/resourcegroups/(?<resourceGroup>[^/]+)/providers/Microsoft.Web/sites/(?<name>[^/]+)")
    if ($match.Success -and $workloads -notcontains $appResourceId)
    {
        $workloads += @{
            id = $appResourceId
            subscriptionID = $match.Groups["subscriptionId"].Value
            resourceGroup = $match.Groups["resourceGroup"].Value
            name = $match.Groups["name"].Value
            appType = $record.AppType
        }
    }

    if ($record.TimeGenerated -gt $lastAccessed.eventDate)
    {
        $lastAccessed.eventDate = $record.TimeGenerated
    }

    # Add your logic to handle the certificate expiration date
    Write-Host "secret: $secretName, expiration date: $expirationDate"
}

# Output the results
if ($secrets.Count -ne 0)
{
    Push-OutputBinding -Name Secrets -Value $secrets -Clobber
}
if ($accessEvents.Count -ne 0)
{
    Push-OutputBinding -Name Access -Value $accessEvents -Clobber
}
if ($workloads.Count -ne 0)
{
    Push-OutputBinding -Name Workloads -Value $workloads -Clobber
}
if ($lastAccessed.eventDate -ne $ConfigIn[0].eventDate)
{
    Push-OutputBinding -Name ConfigOut -Value $lastAccessed -Clobber
}

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
