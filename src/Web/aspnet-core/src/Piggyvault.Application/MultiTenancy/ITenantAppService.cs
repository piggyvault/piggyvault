using Abp.Application.Services;
using Piggyvault.MultiTenancy.Dto;

namespace Piggyvault.MultiTenancy
{
    public interface ITenantAppService : IAsyncCrudAppService<TenantDto, int, PagedTenantResultRequestDto, CreateTenantDto, TenantDto>
    {
    }
}

