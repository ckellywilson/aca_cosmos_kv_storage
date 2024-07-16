namespace contextmapimage;

public static class ApiEndpoints
{
    public static void RegisterEndpoints(this WebApplication endpoints)
    {
        endpoints.MapGet("/health", () =>
        {
            return Results.Ok("Healthy");
        });
    }
}
