using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using Piggyvault.Configuration;
using Piggyvault.Web;

namespace Piggyvault.EntityFrameworkCore
{
    /* This class is needed to run "dotnet ef ..." commands from command line on development. Not used anywhere else */
    public class PiggyvaultDbContextFactory : IDesignTimeDbContextFactory<PiggyvaultDbContext>
    {
        public PiggyvaultDbContext CreateDbContext(string[] args)
        {
            var builder = new DbContextOptionsBuilder<PiggyvaultDbContext>();
            var configuration = AppConfigurations.Get(WebContentDirectoryFinder.CalculateContentRootFolder());

            PiggyvaultDbContextConfigurer.Configure(builder, configuration.GetConnectionString(PiggyvaultConsts.ConnectionStringName));

            return new PiggyvaultDbContext(builder.Options);
        }
    }
}
