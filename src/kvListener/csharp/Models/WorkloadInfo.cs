using Azure.Monitor.Query.Models;
using System.Text.RegularExpressions;

public class WorkloadInfo
{
    public string Id { get; set; }
    public string SubscriptionID { get; set; }
    public string ResourceGroup { get; set; }
    public string Name { get; set; }
    public string AppType { get; set; }

    public WorkloadInfo(LogsTableRow row)
    {
        var appResourceId = row["AppResourceId"].ToString();
        Id = appResourceId.Replace('/', '_');
        var match = Regex.Match(appResourceId, @"/subscriptions/(?<subscriptionId>[^/]+)/resourcegroups/(?<resourceGroup>[^/]+)/providers/(?<provider>[^/]+)/(?<resourceType>[^/]+)/(?<name>[^/]+)");

        if (match.Success)
        {
            SubscriptionID = match.Groups["subscriptionId"].Value;
            ResourceGroup = match.Groups["resourceGroup"].Value;
            Name = match.Groups["name"].Value;
        }
        else
        {
            SubscriptionID = string.Empty;
            ResourceGroup = string.Empty;
            Name = string.Empty;
        }

        AppType = row["AppType"].ToString();
    }
}