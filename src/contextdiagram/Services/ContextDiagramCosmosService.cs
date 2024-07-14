using System;
using System.Collections.Generic;
using System.Reflection.Metadata.Ecma335;
using System.Threading.Tasks;

namespace YourNamespace
{
    public class ContextDiagramCosmosService : IContextDiagramService
    {
        readonly IEnumerable<ContextDiagram>? _contextDiagrams;

        public ContextDiagramCosmosService()
        {
            _contextDiagrams =
            [
                new ContextDiagram { Id = "1", Name = "Context Diagram 1" },
                new ContextDiagram { Id = "2", Name = "Context Diagram 2" },
                new ContextDiagram { Id = "3", Name = "Context Diagram 3" }
            ];
        }

        public async Task<ContextDiagram> GetContextDiagramAsync(string id)
        {
            return await Task.Run<ContextDiagram>(() =>
            {
                return _contextDiagrams?.FirstOrDefault(cd => cd.Id == id) ?? throw new KeyNotFoundException();
            });
        }
    }
}