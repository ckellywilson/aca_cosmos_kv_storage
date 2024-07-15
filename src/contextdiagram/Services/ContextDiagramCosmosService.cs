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

        public async Task AddContextDiagramAsync(ContextDiagram contextDiagram)
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

        public async Task<ContextDiagram> GetContextDiagramAsync(string id)
        {
            var container = _client.GetContainer(_database, _container);
            try
            {
                var response = await container.ReadItemAsync<ContextDiagram>(id, new PartitionKey(id));
                return response.Resource;
            }
            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                throw new KeyNotFoundException();
            }
        }
    }
}