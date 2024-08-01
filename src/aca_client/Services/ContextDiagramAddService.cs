using aca_client.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Json;
using System.Text;
using System.Threading.Tasks;

namespace aca_client.Services
{
    internal class ContextDiagramAddService : IAPIService
    {
        private string _apiEndpoint;
        private HttpClient _client;
        private List<string> _containers = new List<string>();
        public ContextDiagramAddService(string apiEndpoint, HttpClient client)
        {
            _apiEndpoint = apiEndpoint;
            _client = client;
            _containers = new List<string>();
        }

        public string APIEndpoint => _apiEndpoint;

        public IEnumerable<string> Containers => _containers;

        public async Task Execute()
        {
            IEnumerable<ContextItem> items = new List<ContextItem>
            {
                new ContextItem
                {
                    id = Guid.NewGuid().ToString(),
                    name = "Diagram 1",
                    category = "Flow"
                },
                new ContextItem
                {
                    id = Guid.NewGuid().ToString(),
                    name = "Diagram 2",
                    category = "Flow"
                }
            };

            foreach (var item in items)
            {
                using (var request = new HttpRequestMessage(HttpMethod.Post, $"{_apiEndpoint}api/contextitems"))
                {
                    request.Content = JsonContent.Create(item);
                    var response = await _client.SendAsync(request);

                    if (!response.IsSuccessStatusCode)
                    {
                        throw new Exception($"Failed to add context item: {response.ReasonPhrase}");
                    }

                    _containers.Add(item.id);
                }
            }
        }
    }
}
