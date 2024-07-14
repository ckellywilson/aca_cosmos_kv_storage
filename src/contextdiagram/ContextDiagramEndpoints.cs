using System.Reflection.Metadata.Ecma335;
using System.Runtime.CompilerServices;
using Microsoft.AspNetCore.Http.HttpResults;

public static class ContextDiagramEndpoints
{
    public static void RegisterEndpoints(this WebApplication endpoints)
    {
        endpoints.MapGet("/contextdiagrams{id}", GetContextDiagram);
    }

    private static async Task<Results<Ok<ContextDiagram>, NotFound>> GetContextDiagram(string id, IContextDiagramService service) =>

        await service.GetContextDiagramAsync(id)
        is ContextDiagram contextDiagram
        ? TypedResults.Ok(contextDiagram) :
        TypedResults.NotFound();
}
