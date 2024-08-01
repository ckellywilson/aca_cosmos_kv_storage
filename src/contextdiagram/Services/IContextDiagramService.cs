public interface IContextDiagramService
{
    Task<IEnumerable<ContextItem>> GetContextDiagramsAsync();
    Task<ContextItem> GetContextDiagramAsync(string id);
    Task AddContextDiagramAsync(ContextItem contextDiagram);
}
