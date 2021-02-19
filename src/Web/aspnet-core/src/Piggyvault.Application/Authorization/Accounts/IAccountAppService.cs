using Abp.Application.Services;
using Piggyvault.Authorization.Accounts.Dto;
using System.Threading.Tasks;

namespace Piggyvault.Authorization.Accounts
{
    public interface IAccountAppService : IApplicationService
    {
        Task<IsTenantAvailableOutput> IsTenantAvailable(IsTenantAvailableInput input);

        Task<RegisterOutput> Register(RegisterInput input);

        Task SendPasswordResetCode(SendPasswordResetCodeInput input);

        Task<bool> ResetPassword(ResetPasswordInput input);
    }
}