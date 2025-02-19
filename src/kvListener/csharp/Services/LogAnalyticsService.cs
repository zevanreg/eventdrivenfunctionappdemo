using System;
using System.Threading.Tasks;
using Azure;
using Azure.Identity;
using Azure.Monitor.Query;
using Azure.Monitor.Query.Models;

public class LogAnalyticsService
{
    private readonly string _workspaceId;
    private readonly string _keyVaultName;
    private readonly LogsQueryClient _logsQueryClient;
    private readonly string _funcAppResourceId;

    public LogAnalyticsService(string workspaceId, string keyVaultName, string funcAppResourceId)
    {
        _workspaceId = workspaceId;
        _keyVaultName = keyVaultName;
        _logsQueryClient = new LogsQueryClient(new DefaultAzureCredential());
        _funcAppResourceId = funcAppResourceId;
    }

    public async Task<LogsQueryResult> ExecuteQueryAsync(string eventDate)
    {
        var query = $@"
        AzureDiagnostics
        | where TimeGenerated > datetime('{eventDate}') and ResourceProvider == 'MICROSOFT.KEYVAULT' and Resource =~ '{_keyVaultName}' and OperationName == 'SecretGet' and Category == 'AuditEvent' and identity_claim_xms_az_rid_s != '' and identity_claim_xms_az_rid_s !~ '{_funcAppResourceId}'
        | extend requestUri_base = strcat_array(array_slice(split(requestUri_s, '/'), 0, -2), '/')
        | summarize arg_max(TimeGenerated, *) by identity_claim_xms_az_rid_s, requestUri_base
        | project SubscriptionId, ResourceGroup, AppResourceId = identity_claim_xms_az_rid_s, CertificateUri = requestUri_base, KeyvaultName = Resource, KeyVaultResourceId = ResourceId, AppType = identity_claim_idtyp_s, TimeGenerated
        ";

        Response<LogsQueryResult> response = await _logsQueryClient.QueryWorkspaceAsync(_workspaceId, query, QueryTimeRange.All);
        return response.Value;
    }
}
