using contextdiagram.Exceptions;
using Microsoft.Azure.Cosmos;

namespace contextdiagram.Services
{
    public class ContextDiagramCosmosService : IContextDiagramService
    {
        CosmosClient _client;
        readonly string _database = "Context";
        readonly string _container = "ContextDiagram";

        public ContextDiagramCosmosService(CosmosClient client)
        {
            _client = client;
        }

        public async Task AddContextDiagramAsync(ContextItem contextDiagram)
        {
            var container = _client.GetContainer(_database, _container);
            try
            {
                await container.CreateItemAsync(contextDiagram, new PartitionKey(contextDiagram.id));
            }
            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.Conflict)
            {
                throw new ConflictException("id already exists");
            }
            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.BadRequest)
            {
                throw new BadRequestException("id is required");
            }
        }

        public async Task<ContextItem> GetContextDiagramAsync(string id)
        {
            var container = _client.GetContainer(_database, _container);
            try
            {
                var response = await container.ReadItemAsync<ContextItem>(id, new PartitionKey(id));
                return response.Resource;
            }
            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                throw new KeyNotFoundException();
            }
        }

        public async Task<IEnumerable<ContextItem>> GetContextDiagramsAsync()
        {
            var container = _client.GetContainer(_database, _container);
            var contextItems = new List<ContextItem>();

            try
            {
                using FeedIterator<ContextItem> feed = container.GetItemQueryIterator<ContextItem>(
                    queryText: "SELECT * FROM ContextItem"
);

                // Iterate query result pages
                while (feed.HasMoreResults)
                {
                    FeedResponse<ContextItem> response = await feed.ReadNextAsync();

                    // Iterate query results
                    foreach (ContextItem item in response)
                    {
                        contextItems.Add(item);
                    }
                }
            }
            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                throw new KeyNotFoundException();
            }

            return contextItems;
        }
    }
}