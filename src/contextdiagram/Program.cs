using contextdiagram.Services;
using Microsoft.Azure.Cosmos;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IContextDiagramService, ContextDiagramCosmosService>();
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


