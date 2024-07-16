using Microsoft.AspNetCore.Mvc;

namespace contextmapimage;

public static class ApiEndpoints
{
    public static void RegisterEndpoints(this WebApplication endpoints)
    {
        endpoints.MapGet("/health", () =>
        {
            return Results.Ok("Healthy");
        });

        endpoints.MapPost("/api/Containers", async ([FromServices] IBlobStorageService blobStorageService, [FromBody] string containerName) =>
        {
            var result = await blobStorageService.CreateContainerAsync(containerName);

            if (result)
            {
                return Results.Ok("Container created successfully");
            }

            return Results.BadRequest("Container creation failed");
        });

        endpoints.MapPost("/api/Blobs", async ([FromServices] IBlobStorageService blobStorageService, [FromForm] IFormFile file) =>
        {
            if (file is null)
            {
                return Results.BadRequest("File is null");
            }

            if (file.Length == 0)
            {
                return Results.BadRequest("File is empty");
            }

            var blobName = Guid.NewGuid().ToString();
            var content = new MemoryStream();
            await file.CopyToAsync(content);
            content.Position = 0;

            var containerName = "contextmapimage";
            var result = await blobStorageService.UploadBlobAsync(containerName, blobName, content);

            if (result)
            {
                return Results.Ok("File uploaded successfully");
            }

            return Results.BadRequest("File upload failed");
        }).DisableAntiforgery();
    }
}
