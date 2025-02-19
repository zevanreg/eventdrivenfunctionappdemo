using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Linq;
using System.Threading.Tasks;

namespace kvReader
{
    public class KeyVaultReader
    {
        private readonly KeyVaultService _keyVaultService;
        private readonly ILogger<KeyVaultReader> _logger;

        public KeyVaultReader(KeyVaultService keyVaultService, ILogger<KeyVaultReader> logger)
        {
            _keyVaultService = keyVaultService;
            _logger = logger;
        }

        [Function("KeyVaultReader")]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _logger.LogInformation("Processing request...");

            if (req == null)
            {
                _logger.LogError("HttpRequestData is null.");
                return new BadRequestObjectResult("HttpRequestData is null.");
            }

            var query = System.Web.HttpUtility.ParseQueryString(req.Url.Query);
            if (!query.AllKeys.Contains("name"))
            {
                return new BadRequestObjectResult("The query string parameter 'name' is required.");
            }

            var secret = await _keyVaultService.GetSecretAsync(query["name"]);
            return new OkObjectResult($"Secret Value: {secret.Value}");
        }
    }
}