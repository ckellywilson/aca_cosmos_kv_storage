using System;
using System.Collections.Generic;
using System.Reflection.Metadata.Ecma335;
using System.Threading.Tasks;

namespace YourNamespace
{
    public class ContextDiagramCosmosService : IContextDiagramService
    {
        public async Task<ContextDiagram> GetContextDiagramAsync(string id)
        {
            return await Task.Run<ContextDiagram>(() => new ContextDiagram { Id = id, Name = "Context Diagram" });
        }
    }
}