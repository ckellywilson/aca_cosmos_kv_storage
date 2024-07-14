using System.Reflection.Metadata.Ecma335;
using System.Runtime.CompilerServices;
using Microsoft.AspNetCore.Http.HttpResults;

public static class ContextDiagramEndpoints
{
    public static void RegisterEndpoints(this WebApplication endpoints)
    {
        endpoints.MapGet("/contextdiagrams/{id}", GetContextDiagram);
    }

    private static async Task<Results<Ok<ContextDiagram>, NotFound>> GetContextDiagram(string id, IContextDiagramService service)
    {
        try
        {
            var contextDiagram = await service.GetContextDiagramAsync(id);
            return TypedResults.Ok(contextDiagram);
        }
        catch (KeyNotFoundException)
        {
            return TypedResults.NotFound();
        }
    }


}
