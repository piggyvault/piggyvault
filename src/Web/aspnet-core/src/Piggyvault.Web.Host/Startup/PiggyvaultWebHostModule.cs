using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Abp.Modules;
using Abp.Reflection.Extensions;
using Piggyvault.Configuration;

namespace Piggyvault.Web.Host.Startup
{
    [DependsOn(
       typeof(PiggyvaultWebCoreModule))]
    public class PiggyvaultWebHostModule: AbpModule
    {
        private readonly IWebHostEnvironment _env;
        private readonly IConfigurationRoot _appConfiguration;

        public PiggyvaultWebHostModule(IWebHostEnvironment env)
        {
            _env = env;
            _appConfiguration = env.GetAppConfiguration();
        }

        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(PiggyvaultWebHostModule).GetAssembly());
        }
    }
}
