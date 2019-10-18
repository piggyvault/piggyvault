using System.Threading.Tasks;
using Abp.Application.Services;
using Piggyvault.Sessions.Dto;

namespace Piggyvault.Sessions
{
    public interface ISessionAppService : IApplicationService
    {
        Task<GetCurrentLoginInformationsOutput> GetCurrentLoginInformations();
    }
}
