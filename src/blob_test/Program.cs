using System.Globalization;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Microsoft.VisualBasic;

internal class Program
{
    const string _containerName = "contextmapimage";
    const string _contextDiagramId = "2e88c653-7875-4c7e-a49f-91bb475778a0";
    static IDictionary<string, string> _tags = new Dictionary<string, string>(){
        {"contextdiagramid",_contextDiagramId},
        {"category","Flow"}
    };
    const string _blobData = "Hello from blob content";
    static string _baseBlobUrl = null;
    private async static Task Main(string[] args)
    {
        Console.WriteLine("Set Environment Variables via the Debug menu and setting the environmental properties");
        Console.WriteLine("BLOB_STORAGE_URL, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_TENANT_ID");

        //Environment.SetEnvironmentVariable("BLOB_STORAGE_URL", "https://ecolabsah2gwkp7igk2k2.blob.core.windows.net");
        //Environment.SetEnvironmentVariable("AZURE_CLIENT_ID", "53765060-07f4-4acd-9caa-87268604a361");
        //Environment.SetEnvironmentVariable("AZURE_CLIENT_SECRET", "~zM8Q~acyMFugQay2D859xv21Ziq11DcOvF.Ddfv");
        //Environment.SetEnvironmentVariable("AZURE_TENANT_ID", "93366ed2-d3b1-450b-9a7a-97c613864bad");

        //set _baseBlobUrl from Environment Variable
        _baseBlobUrl = Environment.GetEnvironmentVariable("BLOB_STORAGE_URL") ??
            throw new ArgumentNullException("BLOB_STORAGE_URL is not set");

        await CreateBlobContainerAsync();
        await UploadBlobAsync();
    }

    private static async Task UploadBlobAsync()
    {
        string blobContainerUrl = $"{_baseBlobUrl}/{_containerName}";
        try
        {
            var containerClient = new BlobContainerClient(new Uri(blobContainerUrl), new DefaultAzureCredential());
            var blobClient = containerClient.GetBlobClient(_contextDiagramId);

            await blobClient.UploadAsync(BinaryData.FromString(_blobData));
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
        }
    }

    private static async Task CreateBlobContainerAsync()
    {
        string blobContainerUrl = $"{_baseBlobUrl}/{_containerName}";

        try
        {
            BlobContainerClient containerClient = new BlobContainerClient(
                blobContainerUri: new Uri(blobContainerUrl),
                credential: new DefaultAzureCredential());

            await containerClient.CreateIfNotExistsAsync();
        }
        catch (System.Exception ex)
        {
            Console.WriteLine(ex.Message);
        }
    }
}