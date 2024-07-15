using contextdiagram.Services;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.DependencyInjection; // Add this line

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IContextDiagramService, ContextDiagramCosmosService>();

// set Application Insights telemetry
if (Environment.GetEnvironmentVariable("APPLICATIONINSIGHTS_CONNECTION_STRING") != null)
{
    builder.Services.AddApplicationInsightsTelemetry();
}


if (Environment.GetEnvironmentVariable("COSMOS_CONNECTION_STRING") == null)
{
    throw new KeyNotFoundException("COSMOS_CONNECTION_STRING environment variable is required to connect to the Cosmos DB");
}

builder.Services.AddSingleton<CosmosClient>(new CosmosClient(Environment.GetEnvironmentVariable("COSMOS_CONNECTION_STRING")));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// app.UseHttpsRedirection();


//register the endpoints
app.RegisterEndpoints();

// run app
app.Run();


