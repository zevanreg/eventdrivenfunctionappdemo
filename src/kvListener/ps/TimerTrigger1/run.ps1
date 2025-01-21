# Input bindings are passed in via param block.
param($Timer, $ConfigIn)

$lastAccessed = $ConfigIn

$secureClientSecret = ConvertTo-SecureString $env:AZURE_CLIENT_SECRET -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($env:AZURE_CLIENT_ID, $secureClientSecret)

Connect-AzAccount -ServicePrincipal -TenantId $env:AZURE_TENANT_ID -Credential $credential


# Define the Kusto query
$query = @"
AzureDiagnostics
| where Category == 'AuditEvent' and ResourceProvider == 'MICROSOFT.KEYVAULT' and OperationName == 'SecretGet' and identity_claim_xms_az_rid_s != '' and Resource == '$env:keyVaultName' and TimeGenerated > datetime('$(lastAccessed.eventDate)')
| project AppResourceId=identity_claim_xms_az_rid_s, CertificateUri=requestUri_s, KeyvaultName=Resource, KeyVaultResourceId = ResourceId, TimeGenerated
"@

# Make a Kusto query to get CertificateGet events
$queryResults = Invoke-AzOperationalInsightsQuery -WorkspaceId $env:workspaceId -Query $query

# Iterate results
foreach ($record in $queryResults.Results) {
    # Parse CertificateUri to get the certificate name
    $secretUri = $record.CertificateUri
    $regex = [regex]::new("https://[^/]+/secrets/([^/?]+)")
    $result = $regex.Match($secretUri)
    $secretName = $result.Groups[1].Value


    # Get the secret from Key Vault
    $secret = Get-AzKeyVaultSecret -VaultName $record.KeyvaultName -Name $secretName

    # Extract the expiration date
    $expirationDate = $secret.Attributes.Expires


    $secrets += @{ 
        id = $record.CertificateUri -replace '/', '_'
        akvName = $record.KeyvaultName
        secretName = $secretName
        expiryDate = $expirationDate
    }

    $accessEvents += @{ 
        id = $record.properties.id.SubString(0, $record.properties.id.LastIndexOf('/')) -replace '/', '_'
        objectId = $record.identity.claim.xms_az_rid -replace '/', '_'
        akvName = $data.VaultName
        secretName = $name
        lastAccessed = $record.time
        subscriptionId = $data.SubscriptionId
        resourceGroup = $data.ResourceGroupName
    }

    $workloads += @{
        id = $record.identity.claim.xms_az_rid -replace '/', '_'
        subscriptionID = $identity.SubscriptionId
        resourceGroup = $identity.ResourceGroupName
        name = $identity.ResourceName
        appType = $record.identity.claim.idtyp
    }

    if ($record.TimeGenerated -gt $lastAccessed.eventDate)
    {
        $lastAccessed.eventDate = $record.TimeGenerated
    }

    # Add your logic to handle the certificate expiration date
    Write-Host "secret: $secretName, Expiration Date: $expirationDate"


}

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


Push-OutputBinding -Name ConfigOut -Value $lastAccessed -Clobber


# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}






# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
