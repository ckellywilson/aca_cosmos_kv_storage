
using Azure;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

namespace contextmapimage;

public class AzureBlobStoreService : IBlobStorageService
{

    private readonly BlobServiceClient _blobServiceClient;
    static IDictionary<string, string>? _tags;

    public AzureBlobStoreService(BlobServiceClient blobServiceClient)
    {
        _blobServiceClient = blobServiceClient;
    }

    public async Task<bool> CreateContainerAsync(string containerName)
    {
        try
        {
            // Create the container
            BlobContainerClient containerClient = await _blobServiceClient.CreateBlobContainerAsync(containerName);

            if (await containerClient.ExistsAsync())
            {
                return true;
            }
        }
        catch (RequestFailedException ex)
        {
            if (!string.IsNullOrEmpty(ex.ErrorCode) && ex.ErrorCode == "ContainerAlreadyExists")
            {
                return true;
            }

            return false;
        }

        return true;
    }

    public async Task<bool> UploadBlobAsync(string containerName, string blobName, Stream content)
    {
        _tags = new Dictionary<string, string>(){
            {"contextdiagramid",blobName},
            {"category","Flow"}
        };

        try
        {
            BlobContainerClient containerClient;

            try
            {
                containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
                if (!await containerClient.ExistsAsync())
                {
                    await CreateContainerAsync(containerName);
                }
            }
            catch (RequestFailedException ex)
            {
                if (!string.IsNullOrEmpty(ex.ErrorCode) && ex.ErrorCode == "ContainerAlreadyExists")
                {
                    return true;
                }
                return false;
            }

            // Get a reference to a blob
            BlobClient blobClient = containerClient.GetBlobClient(blobName);

            await blobClient.UploadAsync(BinaryData.FromStream(content),
            new BlobUploadOptions() { Tags = _tags });
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
            return false;
        }

        return true;
    }
}
