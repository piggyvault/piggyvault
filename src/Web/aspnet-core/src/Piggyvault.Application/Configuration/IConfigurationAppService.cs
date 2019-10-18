using System.Threading.Tasks;
using Piggyvault.Configuration.Dto;

namespace Piggyvault.Configuration
{
    public interface IConfigurationAppService
    {
        Task ChangeUiTheme(ChangeUiThemeInput input);
    }
}
