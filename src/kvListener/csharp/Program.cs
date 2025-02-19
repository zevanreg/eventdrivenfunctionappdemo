using System.Text.Json;
using Azure.Core.Serialization;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

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
        services.Configure<WorkerOptions>(bo =>
        {
            bo.Serializer = new JsonObjectSerializer(
                new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                    DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull
                });
        });
        var workspaceId = context.Configuration["workspaceId"];
        var keyVaultName = context.Configuration["keyVaultName"];
        var functionAppResourceId = context.Configuration["functionAppResourceId"];
        services.AddSingleton<KeyVaultService>(provider =>
        {
            return new KeyVaultService(keyVaultName);
        });
        services.AddSingleton<LogAnalyticsService>(provider =>
        {
            return new LogAnalyticsService(workspaceId, keyVaultName, functionAppResourceId);
        });
        services.AddLogging();
    })
    .Build();

host.Run();
