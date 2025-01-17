using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using System.Threading.Tasks;

namespace kvListener
{
    public class KeyVaultReader
    {
        private readonly ILogger<KeyVaultReader> _logger;
        private readonly SecretClient _secretClient;

        public KeyVaultReader(ILogger<KeyVaultReader> logger)
        {
            _logger = logger;
            string userAssignedClientId = "5871930e-6d3b-4084-9832-853d877ec091";
            var credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions { ManagedIdentityClientId = userAssignedClientId });

            _secretClient = new SecretClient(new Uri("https://keyVaultjmyuijr4avckq.vault.azure.net/"), credential);
        }

        [Function("KeyVaultReader")]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequest req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            KeyVaultSecret secret = await _secretClient.GetSecretAsync(req.Query["name"]);
            string secretValue = secret.Value;

            return new OkObjectResult($"Secret Value: {secretValue}");
        }
    }
}