public interface IContextDiagramService
{
    Task<ContextDiagram> GetContextDiagramAsync(string id);
}
