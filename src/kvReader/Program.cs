using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

var builder = FunctionsApplication.CreateBuilder(args);

builder.ConfigureFunctionsWebApplication();

// Application Insights isn't enabled by default. See https://aka.ms/AAt8mw4.
// builder.Services
//     .AddApplicationInsightsTelemetryWorkerService()
//     .ConfigureFunctionsApplicationInsights();

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureServices((context, services) =>
    {
        var keyVaultName = context.Configuration["keyVaultName"];
        services.AddSingleton<KeyVaultService>(provider =>
        {
            var logger = provider.GetRequiredService<ILogger<KeyVaultService>>();
            return new KeyVaultService(keyVaultName, logger);
        });
        services.AddLogging();
    })
    .Build();

host.Run();

