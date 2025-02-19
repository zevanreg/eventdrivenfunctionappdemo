using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Azure;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

public class KeyVaultService
{
    private readonly DefaultAzureCredential _credential;
    private readonly SecretClient _secretClient;

    public KeyVaultService(string keyVaultName)
    {
        _credential = new DefaultAzureCredential();
        var keyVaultUri = new Uri($"https://{keyVaultName}.vault.azure.net/");
        _secretClient = new SecretClient(keyVaultUri, _credential);
    }

    public async Task<KeyVaultSecret> GetSecretAsync(string secretName)
    {
        try
        {
            return await _secretClient.GetSecretAsync(secretName);
        }
        catch (RequestFailedException ex) when (ex.Status == 404)
        {
            // Secret not found
            return null;
        }
        catch (Exception ex)
        {
            // Handle other exceptions (e.g., access denied)
            throw new Exception($"Error retrieving secret '{secretName}': {ex.Message}", ex);
        }
    }
}
