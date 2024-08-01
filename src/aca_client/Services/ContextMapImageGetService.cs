using aca_client.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Json;
using System.Text;
using System.Threading.Tasks;

namespace aca_client.Services
{
    internal class ContextMapImageGetService : IAPIService
    {
        private string _apiEndpoint;
        private HttpClient _client;
        private List<string> _containers = new List<string>();

        public ContextMapImageGetService(string apiEndpoint, HttpClient client)
        {
            _apiEndpoint = apiEndpoint;
            _client = client;
        }

        public IEnumerable<string> Containers => _containers;

        public string APIEndpoint => _apiEndpoint;

        public async Task Execute()
        {
            using (var request = new HttpRequestMessage(HttpMethod.Get, $"{_apiEndpoint}api/containers"))
            {
                var response = await _client.SendAsync(request);

                if (!response.IsSuccessStatusCode)
                {
                    throw new Exception($"Failed to get containers: {response.ReasonPhrase}");
                }

                var containerItems = await response.Content.ReadFromJsonAsync<IEnumerable<BlobContainerItemDTO>>();

                if (containerItems == null)
                {
                    throw new Exception("Failed to deserialize container items");
                }

                foreach (var container in containerItems)
                {
                    _containers.Add(container.Name);
                }
            }
        }
    }
}
