using cosmos_test;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Cosmos.Serialization.HybridRow.Schemas;
using Microsoft.Extensions.Configuration;

// add configuration to the project as per https://learn.microsoft.com/en-us/dotnet/core/extensions/configuration
internal class Program
{
    private static string _cosmosConnectionString;
    private static void Main(string[] args)
    {
        Console.WriteLine("Add Configuration");
        AddConfiguration();

        try
        {
            Task.Run(async () => await CreateItem()).Wait();
        }
        catch (AggregateException ex)
        {
            Console.WriteLine("An error occurred: " + ex.InnerExceptions[0].ToString());
        }
    }

    private static void AddConfiguration()
    {
        IConfigurationRoot config = new ConfigurationBuilder()
            .AddJsonFile("appSettings.json")
               .AddEnvironmentVariables()
               .Build();

        _cosmosConnectionString = config.GetConnectionString("CosmosDB") ??
                throw new NullReferenceException("CosmosDB Connection String is null");
    }

    static async Task CreateItem()
    {
        //variables
        var databaseName = "Context";
        var containerName = "ContextDiagram";
        var insertId = Guid.NewGuid().ToString();

        ContextDiagram item = new()
        {
            id = insertId,
            name = "Diagram 1",
            category = "Flow"
        };

        // New instance of CosmosClient class using a connection string
        using CosmosClient client = new(
            connectionString: _cosmosConnectionString);

        // Create a new database
        Database database = client.GetDatabase(databaseName);

        // Create a new container
        Container container = database.GetContainer(containerName);

        // Create a new item
        ContextDiagram upsertedItem = await container.UpsertItemAsync<ContextDiagram>(
            item: item,
            partitionKey: new Microsoft.Azure.Cosmos.PartitionKey(item.id)
            );

        Console.WriteLine("Client: " + upsertedItem.id);
    }
}