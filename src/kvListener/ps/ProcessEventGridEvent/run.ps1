param($eventGridEvent, $TriggerMetadata)

# Make sure to pass hashtables to Out-String so they're logged correctly
$eventGridEvent | Out-String | Write-Host
$eventGridEvent.data | Out-String | Write-Host
$id = $eventGridEvent.data.Id.SubString(0, $eventGridEvent.data.Id.LastIndexOf('/')) -replace '/', '_'
$id | Out-String | Write-Host

$dateTime = $null
if ($null -ne $eventGridEvent.data.EXP) {
    $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
    $dateTime = $origin.AddSeconds($eventGridEvent.data.EXP)
}

Push-OutputBinding -Name Secrets -Value @{ 
        id = $id
        akvName = $eventGridEvent.data.VaultName
        secretName = $eventGridEvent.data.ObjectName
        expiryDate = $dateTime
}