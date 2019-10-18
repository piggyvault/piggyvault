using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Piggyvault.Roles.Dto;
using Piggyvault.Users.Dto;

namespace Piggyvault.Users
{
    public interface IUserAppService : IAsyncCrudAppService<UserDto, long, PagedUserResultRequestDto, CreateUserDto, UserDto>
    {
        Task<ListResultDto<RoleDto>> GetRoles();

        Task ChangeLanguage(ChangeUserLanguageDto input);
    }
}
