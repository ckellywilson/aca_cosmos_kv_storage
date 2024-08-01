using aca_client.Services;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Text.Json.Nodes;

internal class Program
{
    private static async Task Main(string[] args)
    {
        Console.WriteLine("Set Configuration");
        await SetConfiguration();

        Console.WriteLine("Register Services");
        var services = await RegisterServices();

        foreach (var service in services)
        {
            Console.WriteLine($"Service: {service.GetType().FullName} at API {service.APIEndpoint}");
            await service.Execute();
        }

        Console.WriteLine("Press any key to continue...");
        Console.ReadLine();
    }

    private static async Task SetConfiguration()
    {
        await Task.Run(() =>
        {
            IConfigurationRoot config = new ConfigurationBuilder()
             .AddJsonFile("APISettings.template.json")
                .AddEnvironmentVariables()
                .Build();

            var apiSettings = config.GetSection("APISettings");

            foreach (var setting in apiSettings.GetChildren())
            {
                Console.WriteLine($"Set Environment Variable: '{setting.Key}': '{setting.Value}'");
                Environment.SetEnvironmentVariable(setting.Key, setting.Value);

                Console.WriteLine($"Check Environment Variable '{setting.Key}': '{Environment.GetEnvironmentVariable(setting.Key)}'");
            }
        });
    }

    private static Task<IEnumerable<IAPIService>> RegisterServices()
    {
        var contextDiagramAddService = new ContextDiagramAddService(Environment.GetEnvironmentVariable("contextdiagramAPIEndpoint") ??
            throw new NullReferenceException("Environment variable contextdiagramAPIEndpoint not found"),
            new HttpClient());

        var contextMapImageAddService = new ContextMapImageAddService(Environment.GetEnvironmentVariable("contextmapimageAPIEndpoint") ??
            throw new NullReferenceException("Environment variable contextmapimageAPIEndpoint not found"),
            new HttpClient(),contextDiagramAddService.Containers);

        IEnumerable<IAPIService> services = new List<IAPIService>
        {
            contextDiagramAddService,
            contextMapImageAddService
        };

        return Task.FromResult(services);
    }
}