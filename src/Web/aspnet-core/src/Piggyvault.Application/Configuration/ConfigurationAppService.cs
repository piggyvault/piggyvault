using System.Threading.Tasks;
using Abp.Authorization;
using Abp.Runtime.Session;
using Piggyvault.Configuration.Dto;

namespace Piggyvault.Configuration
{
    [AbpAuthorize]
    public class ConfigurationAppService : PiggyvaultAppServiceBase, IConfigurationAppService
    {
        public async Task ChangeUiTheme(ChangeUiThemeInput input)
        {
            await SettingManager.ChangeSettingForUserAsync(AbpSession.ToUserIdentifier(), AppSettingNames.UiTheme, input.Theme);
        }
    }
}
