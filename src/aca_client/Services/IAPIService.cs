using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace aca_client.Services
{
    internal interface IAPIService : IAPI
    {
        IEnumerable<string> Containers { get; }
        Task Execute();
    }
}
