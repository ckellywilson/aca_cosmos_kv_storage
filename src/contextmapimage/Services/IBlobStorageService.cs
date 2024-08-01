using Azure.Storage.Blobs.Models;

namespace contextmapimage;

public interface IBlobStorageService
{
    Task<IEnumerable<BlobContainerItem>> GetContainersAsync();
    Task<bool> CreateContainerAsync(string containerName);
    Task<bool> UploadBlobAsync(string containerName, string blobName, Stream content);
}
