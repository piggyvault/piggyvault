using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Piggyvault.Roles.Dto;
using Piggyvault.Users.Dto;
using System.Threading.Tasks;

namespace Piggyvault.Users
{
    public interface IUserAppService : IAsyncCrudAppService<UserDto, long, PagedUserResultRequestDto, CreateUserDto, UserDto>
    {
        Task ChangeDefaultCurrency(ChangeUserDefaultCurrencyDto input);

        Task DeActivate(EntityDto<long> user);

        Task Activate(EntityDto<long> user);

        Task<ListResultDto<RoleDto>> GetRoles();

        Task ChangeLanguage(ChangeUserLanguageDto input);

        Task<bool> ChangePassword(ChangePasswordDto input);

        Task<UserSettingsDto> GetSettings();
    }
}