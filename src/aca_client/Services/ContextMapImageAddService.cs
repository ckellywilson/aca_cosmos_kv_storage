using aca_client.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Json;
using System.Text;
using System.Threading.Tasks;

namespace aca_client.Services
{
    internal class ContextMapImageAddService : IAPIService
    {
        private string _apiEndpoint;
        private HttpClient _client;
        private List<string> _containers = new List<string>();
        private IEnumerable<string> _contextItems;

        public ContextMapImageAddService(string apiEndpoint, HttpClient client, IEnumerable<string> contextItems)
        {
            _apiEndpoint = apiEndpoint;
            _client = client;
            _containers = new List<string>();
            _contextItems = contextItems;
        }
        public IEnumerable<string> Containers => _containers;

        public string APIEndpoint => _apiEndpoint;
        public async Task Execute()
        {
            foreach (var item in _contextItems)
            {
                using (var request = new HttpRequestMessage(HttpMethod.Post, $"{_apiEndpoint}/api/containers"))
                {
                    request.Content = JsonContent.Create(item);
                    var response = await _client.SendAsync(request);

                    if (!response.IsSuccessStatusCode)
                    {
                        throw new Exception($"Failed to add context item: {response.ReasonPhrase}");
                    }

                    _containers.Add(item);
                }

                using (var request = new HttpRequestMessage(HttpMethod.Post, $"{_apiEndpoint}/api/blobs"))
                {
                    request.Content = new MultipartFormDataContent
                    {
                        {
                            new ByteArrayContent(Encoding.UTF8.GetBytes($"Hello from {item}")), "file", "hello.txt"
                        },
                        {
                            new StringContent(item), "containerName"
                        }
                    };

                    var response = await _client.SendAsync(request);

                    if (!response.IsSuccessStatusCode)
                    {
                        throw new Exception($"Failed to add context item: {response.ReasonPhrase}");
                    }

                    _containers.Add(item);
                }
            }            
        }
    }
}
