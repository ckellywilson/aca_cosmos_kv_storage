
using Azure;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

namespace contextmapimage;

public class AzureBlobStoreService : IBlobStorageService
{

    private readonly BlobServiceClient _blobServiceClient;

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

    public async Task<IEnumerable<BlobContainerItem>> GetContainersAsync()
    {
        List<BlobContainerItem> containers = new List<BlobContainerItem>();
        CancellationToken cancellationToken = new CancellationToken();
        try
        {
            await foreach (BlobContainerItem container in _blobServiceClient.GetBlobContainersAsync(
            traits: BlobContainerTraits.Metadata, cancellationToken: cancellationToken))
            {
                containers.Add(container);
            }
            cancellationToken.ThrowIfCancellationRequested();
        }
        catch (OperationCanceledException)
        {
            return containers;
        }        

        return containers;
    }

    public async Task<bool> UploadBlobAsync(string containerName, string blobName, Stream content)
    {

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

            await blobClient.UploadAsync(BinaryData.FromStream(content));
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
            return false;
        }

        return true;
    }
}
