using Abp.AutoMapper;
using Abp.Modules;
using Abp.Reflection.Extensions;
using Piggyvault.Authorization;

namespace Piggyvault
{
    [DependsOn(
        typeof(PiggyvaultCoreModule),
        typeof(AbpAutoMapperModule))]
    public class PiggyvaultApplicationModule : AbpModule
    {
        public override void PreInitialize()
        {
            Configuration.Authorization.Providers.Add<PiggyvaultAuthorizationProvider>();
        }

        public override void Initialize()
        {
            var thisAssembly = typeof(PiggyvaultApplicationModule).GetAssembly();

            IocManager.RegisterAssemblyByConvention(thisAssembly);

            Configuration.Modules.AbpAutoMapper().Configurators.Add(
                // Scan the assembly for classes which inherit from AutoMapper.Profile
                cfg => cfg.AddMaps(thisAssembly)
            );

            //Adding custom AutoMapper configuration
            Configuration.Modules.AbpAutoMapper().Configurators.Add(CustomDtoMapper.CreateMappings);

            Configuration.BackgroundJobs.IsJobExecutionEnabled = true;
        }
    }
}