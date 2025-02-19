using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Monitor.Query.Models;
using System.Text.RegularExpressions;

namespace KeyVaultEventsReader
{
    public class TimerTrigger
    {
        private readonly ILogger<TimerTrigger> _logger;
        private readonly KeyVaultService _keyVaultService;
        private readonly LogAnalyticsService _logAnalyticsService;

        public TimerTrigger(ILogger<TimerTrigger> logger, KeyVaultService keyVaultService, LogAnalyticsService logAnalyticsService)
        {
            _logger = logger;
            _keyVaultService = keyVaultService;
            _logAnalyticsService = logAnalyticsService;
        }

        [Function("TimerTrigger")]
        public async Task<DBOutput> Run([TimerTrigger("*/10 * * * * *")] TimerInfo myTimer,
        [CosmosDBInput(
            databaseName: "%cosmosDatabaseName%",
            containerName: "%cosmosConfigContainerName%",
            Connection = "cosmosdb",
            Id = "1")] IEnumerable<Config> configItems)
        {
            try
            {
                _logger.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");

                var config = configItems.FirstOrDefault();
                if (config == null)
                {
                    config = new Config
                    {
                        Id = "1",
                        EventDate = DateTime.MinValue.ToString("o")
                    };
                }

                _logger.LogInformation($"Event Date: {config.EventDate}");

                var queryResults = await _logAnalyticsService.ExecuteQueryAsync(config.EventDate);
                var secrets = new List<SecretInfo>();
                var accessEvents = new List<AccessEventInfo>();
                var workloads = new List<WorkloadInfo>();

                var lastEventDate = await ProcessQueryResultsAsync(queryResults, secrets, accessEvents, workloads, config);

                _logger.LogInformation($"Processed {secrets.Count} secrets, {accessEvents.Count} access events, and {workloads.Count} workloads.");

                if (lastEventDate.ToString("o") != config.EventDate)
                {
                    config.EventDate = lastEventDate.ToString("o");
                    return new DBOutput
                    {
                        Secrets = secrets,
                        SecretsAccessedEvents = accessEvents,
                        Workloads = workloads,
                        Config = new List<Config> { config }
                    };
                }
                else
                {
                    return null;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred while processing the timer trigger.");
                throw;
            }
        }

        private async Task<DateTime> ProcessQueryResultsAsync(LogsQueryResult queryResults, List<SecretInfo> secrets, List<AccessEventInfo> accessEvents, List<WorkloadInfo> workloads, Config config)
        {
            DateTime.TryParse(config.EventDate, out DateTime lastEventDate);
            foreach (var row in queryResults.Table.Rows)
            {
                var secretName = ExtractSecretName(row["CertificateUri"].ToString());
                var secret = await _keyVaultService.GetSecretAsync(secretName);

                if (secret == null)
                {
                    _logger.LogWarning($"Secret '{secretName}' not found in Key Vault.");
                    continue;
                }

                secrets.Add(new SecretInfo(row, secretName, secret));
                accessEvents.Add(new AccessEventInfo(row, secretName));
                workloads.Add(new WorkloadInfo(row));

                UpdateConfigLastEventDate(row.GetDateTimeOffset("TimeGenerated").Value.DateTime, ref lastEventDate);
            }
            return lastEventDate;
        }

        private void UpdateConfigLastEventDate(DateTime timeGenerated, ref DateTime lastEventDate)
        {
            if (timeGenerated > lastEventDate)
            {
                lastEventDate = timeGenerated;
            }
        }

        private string ExtractSecretName(string secretUri)
        {
            Regex regex = new Regex("https://[^/]+/secrets/([^/?]+)");
            Match result = regex.Match(secretUri);
            return result.Groups[1].Value;
        }
    }
}
