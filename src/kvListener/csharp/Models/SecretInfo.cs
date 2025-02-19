using System;
using Azure.Monitor.Query.Models;
using Azure.Security.KeyVault.Secrets;

public class SecretInfo
{
    public string Id { get; set; }
    public string AkvName { get; set; }
    public string SecretName { get; set; }
    public DateTime? ExpiryDate { get; set; }

    public SecretInfo(LogsTableRow row, string secretName, KeyVaultSecret secret)
    {
        Id = row["CertificateUri"].ToString().Replace("/", "_");
        AkvName = row["KeyvaultName"].ToString();
        SecretName = secretName;
        ExpiryDate = secret.Properties.ExpiresOn?.DateTime;
    }
}