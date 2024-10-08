using Azure.Identity;
using Azure.Storage.Blobs;
using contextmapimage;
using Microsoft.Extensions.Azure;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSingleton<BlobServiceClient>(x =>
{
    string blobContainerUrl = Environment.GetEnvironmentVariable("BLOB_STORAGE_URL") ??
            throw new ArgumentNullException("BLOB_STORAGE_URL is not set");

    if (blobContainerUrl.EndsWith("/"))
        blobContainerUrl = blobContainerUrl.Substring(0, blobContainerUrl.Length - 1);

    return new BlobServiceClient(new Uri(blobContainerUrl), new DefaultAzureCredential());
});
builder.Services.AddTransient<IBlobStorageService, AzureBlobStoreService>();

// set Application Insights telemetry
if (Environment.GetEnvironmentVariable("APPLICATIONINSIGHTS_CONNECTION_STRING") != null)
{
    builder.Services.AddApplicationInsightsTelemetry();
}


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();

//register the endpoints
app.RegisterEndpoints();

// run app
app.Run();