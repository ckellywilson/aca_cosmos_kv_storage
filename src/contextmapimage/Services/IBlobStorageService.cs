namespace contextmapimage;

public interface IBlobStorageService
{
    Task<bool> CreateContainerAsync(string containerName);
    Task<bool> UploadBlobAsync(string containerName, string blobName, Stream content);
}
