param($eventHubMessage, $TriggerMetadata)

$eventData = $eventHubMessage | ConvertTo-Json -Depth 10 | ConvertFrom-Json

$setEvents = @()
$accessEvents = @()
$workloads = @()

foreach ($record in $eventData.records)
{
    $category = $record.category
    $operation = $record.operationName

    Write-Host "PowerShell eventhub trigger function called for category $category operation $operation"

    if ($record.category -eq 'AuditEvent' -and $record.operationName -eq 'SecretSet')
    {
        $data = Parse-AzureResourceId -resourceId $record.resourceId
        $name = Parse-KeyVaultSecretUrl -secretUrl $record.properties.id
        $expiryDate = Get-ExpiryDate -expiryTime $record.properties.secretProperties.attributes.exp 

        $expiryDate | Write-Host
        $data | Write-Host
        $name | Write-Host


        $setEvents += @{ 
            id = $record.properties.id -replace '/', '_'
            akvName = $data.VaultName
            secretName = $name
            expiryDate = $expiryDate
        }
    }

    if ($record.category -eq 'AuditEvent' -and $record.operationName -eq 'SecretGet' -and $null -ne $record.identity.claim.xms_az_rid)
    {
        $data = Parse-AzureResourceId -resourceId $record.resourceId
        $name = Parse-KeyVaultSecretUrl -secretUrl $record.properties.id
        $identity = Parse-AppIdentityId -resourceId $record.identity.claim.xms_az_rid

        $record | Write-Host

        $data | Write-Host
        $name | Write-Host
        $identity | Write-Host


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
    }

    if ($setEvents.Count -ne 0)
    {
        Push-OutputBinding -Name Secrets -Value $setEvents -Clobber
    }
    if ($accessEvents.Count -ne 0)
    {
        Push-OutputBinding -Name Access -Value $accessEvents -Clobber
    }
    if ($workloads.Count -ne 0)
    {
        Push-OutputBinding -Name Workloads -Value $workloads -Clobber
    }
}
