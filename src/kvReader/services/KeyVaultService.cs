using System;
using System.Threading.Tasks;
using Azure.Core;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Extensions.Logging;

public class KeyVaultService
{
    private readonly DefaultAzureCredential _credential;
    private readonly SecretClient _secretClient;
    private readonly ILogger<KeyVaultService> _logger;

    public KeyVaultService(string keyVaultName, ILogger<KeyVaultService> logger)
    {
        _logger = logger;
        var keyVaultUri = new Uri($"https://{keyVaultName}.vault.azure.net/");
        _secretClient = new SecretClient(keyVaultUri, new DefaultAzureCredential());
    }

    public async Task<KeyVaultSecret> GetSecretAsync(string secretName)
    {
        try
        {
            return await _secretClient.GetSecretAsync(secretName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving secret '{SecretName}'", secretName);
            throw new Exception($"Error retrieving secret '{secretName}': {ex.Message}", ex);
        }
    }
}
