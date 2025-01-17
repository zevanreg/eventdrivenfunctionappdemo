using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Azure.Functions.Worker.Extensions.Sql;
using Microsoft.Extensions.Logging;
using System.IO;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Microsoft.Data.SqlClient;

namespace kvListener
{
    public class TestFunction
    {
        private readonly ILogger _logger;

        public TestFunction(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<TestFunction>();
        }

        // [Function("InsertKeyVault")]
        // [SqlOutput("dbo.KeyVault", "SQLAZURECONNSTR_DefaultConnection")]
        // public async Task<KeyVault> Run(
        //     [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
        // {
        //     try{
        //         _logger.LogInformation("Processing a request to insert a KeyVault object.");

        //         string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
        //         KeyVault keyVault = JsonConvert.DeserializeObject<KeyVault>(requestBody);
        //         _logger.LogInformation(keyVault.Name);

        //         if (await KeyVaultExists(keyVault.Name))
        //         {
        //             _logger.LogInformation($"KeyVault with name {keyVault.Name} already exists.");
        //             return null;
        //         }

        //         _logger.LogInformation("Inserting a KeyVault object.");
        //         return keyVault;
        //     }
        //     catch (Exception ex)
        //     {
        //         _logger.LogError(ex, ex.Message);
        //         _logger.LogError(ex, "An error occurred while processing a request to insert a KeyVault object.");
        //         return null;
        //     }
        // }

        // private async Task<bool> KeyVaultExists(string keyVaultName)
        // {
        //     var connString = Environment.GetEnvironmentVariable("SQLAZURECONNSTR_DefaultConnection", EnvironmentVariableTarget.Process);
        //     using (SqlConnection conn = new SqlConnection(connString))
        //     {
        //         await conn.OpenAsync();
        //         string query = "SELECT COUNT(1) FROM dbo.KeyVault WHERE Name = @Name";
        //         using (SqlCommand cmd = new SqlCommand(query, conn))
        //         {
        //             cmd.Parameters.AddWithValue("@Name", keyVaultName);
        //             int count = (int)await cmd.ExecuteScalarAsync();
        //             _logger.LogInformation(count.ToString());
        //             return count > 0;
        //         }
        //     }
        // }
    }
}