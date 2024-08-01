using System.Reflection.Metadata.Ecma335;
using System.Runtime.CompilerServices;
using contextdiagram.Exceptions;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.Azure.Cosmos;

public static class ApiEndpoints
{
    public static void RegisterEndpoints(this WebApplication endpoints)
    {
        endpoints.MapGet("/health", () =>
        {
            return Results.Ok("Healthy");
        });

        endpoints.MapPost("/contextitems", async (ContextItem contextDiagram, IContextDiagramService service) =>
        {
            try
            {
                await service.AddContextDiagramAsync(contextDiagram);
            }
            catch (ConflictException ex)
            {
                return Results.Conflict(ex.Message);
            }
            catch (BadRequestException ex)
            {
                return Results.BadRequest(ex.Message);
            }

            return Results.Created($"/contextdiagrams/{contextDiagram.id}", contextDiagram);
        });

        endpoints.MapGet("/contextitems/{id}", async (string id, IContextDiagramService service) =>
        {
            try
            {
                var contextDiagram = await service.GetContextDiagramAsync(id);
                return Results.Ok(contextDiagram);
            }
            catch (KeyNotFoundException)
            {
                return Results.NotFound();
            }
        });

        endpoints.MapGet("/contextitems", async (IContextDiagramService service) =>
        {
            try
            {
                var contextDiagram = await service.GetContextDiagramsAsync();
                return Results.Ok(contextDiagram);
            }
            catch (KeyNotFoundException)
            {
                return Results.NotFound();
            }
        });
    }
}
