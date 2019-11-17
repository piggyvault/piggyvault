using Abp.AspNetCore.Mvc.Controllers;
using Abp.IdentityFramework;
using Microsoft.AspNetCore.Identity;

namespace Piggyvault.Controllers
{
    public abstract class PiggyvaultControllerBase: AbpController
    {
        protected PiggyvaultControllerBase()
        {
            LocalizationSourceName = PiggyvaultConsts.LocalizationSourceName;
        }

        protected void CheckErrors(IdentityResult identityResult)
        {
            identityResult.CheckErrors(LocalizationManager);
        }
    }
}
