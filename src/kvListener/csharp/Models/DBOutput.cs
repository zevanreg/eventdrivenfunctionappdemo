using System.Collections.Generic;
using Microsoft.Azure.Functions.Worker;

public class DBOutput
{
    [CosmosDBOutput(
        databaseName: "%cosmosDatabaseName%",
        containerName: "%cosmosSecretsContainerName%",
        Connection = "cosmosdb")]
    public IEnumerable<SecretInfo> Secrets { get; set; }

    [CosmosDBOutput(
        databaseName: "%cosmosDatabaseName%",
        containerName: "%cosmosSecretsAccessContainerName%",
        Connection = "cosmosdb")]
    public IEnumerable<AccessEventInfo> SecretsAccessedEvents { get; set; }

    [CosmosDBOutput(
        databaseName: "%cosmosDatabaseName%",
        containerName: "%cosmosWorkloadsContainerName%",
        Connection = "cosmosdb")]
    public IEnumerable<WorkloadInfo> Workloads { get; set; }

    [CosmosDBOutput(
        databaseName: "%cosmosDatabaseName%",
        containerName: "%cosmosConfigContainerName%",
        Connection = "cosmosdb")]

    public IEnumerable<Config> Config { get; set; }
}