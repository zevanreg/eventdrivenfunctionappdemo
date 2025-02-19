using System;
using Azure.Monitor.Query.Models;

public class AccessEventInfo
{
    public string Id { get; set; }
    public string ObjectId { get; set; }
    public string AkvName { get; set; }
    public string SecretName { get; set; }
    public DateTime LastAccessed { get; set; }
    public string SubscriptionId { get; set; }
    public string ResourceGroup { get; set; }

    public AccessEventInfo(LogsTableRow row, string secretName)
    {
        ObjectId = row["AppResourceId"].ToString().Replace("/", "_");
        AkvName = row["KeyvaultName"].ToString();
        SecretName = secretName;
        LastAccessed = row.GetDateTimeOffset("TimeGenerated").Value.DateTime;
        SubscriptionId = row["SubscriptionId"].ToString();
        ResourceGroup = row["ResourceGroup"].ToString();
        Id = $"{AkvName}_{ObjectId}";
    }
}