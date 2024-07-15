public interface IContextDiagramService
{
    Task<ContextDiagram> GetContextDiagramAsync(string id);
    Task AddContextDiagramAsync(ContextDiagram contextDiagram);
}
