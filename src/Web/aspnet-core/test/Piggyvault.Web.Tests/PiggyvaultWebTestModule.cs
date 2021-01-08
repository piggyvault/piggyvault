using Abp.AspNetCore;
using Abp.AspNetCore.TestBase;
using Abp.Modules;
using Abp.Reflection.Extensions;
using Piggyvault.EntityFrameworkCore;
using Piggyvault.Web.Startup;
using Microsoft.AspNetCore.Mvc.ApplicationParts;

namespace Piggyvault.Web.Tests
{
    [DependsOn(
        typeof(PiggyvaultWebMvcModule),
        typeof(AbpAspNetCoreTestBaseModule)
    )]
    public class PiggyvaultWebTestModule : AbpModule
    {
        public PiggyvaultWebTestModule(PiggyvaultEntityFrameworkModule abpProjectNameEntityFrameworkModule)
        {
            abpProjectNameEntityFrameworkModule.SkipDbContextRegistration = true;
        } 
        
        public override void PreInitialize()
        {
            Configuration.UnitOfWork.IsTransactional = false; //EF Core InMemory DB does not support transactions.
        }

        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(PiggyvaultWebTestModule).GetAssembly());
        }
        
        public override void PostInitialize()
        {
            IocManager.Resolve<ApplicationPartManager>()
                .AddApplicationPartsIfNotAddedBefore(typeof(PiggyvaultWebMvcModule).Assembly);
        }
    }
}