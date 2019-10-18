using Microsoft.EntityFrameworkCore;
using Abp.Zero.EntityFrameworkCore;
using Piggyvault.Authorization.Roles;
using Piggyvault.Authorization.Users;
using Piggyvault.MultiTenancy;

namespace Piggyvault.EntityFrameworkCore
{
    public class PiggyvaultDbContext : AbpZeroDbContext<Tenant, Role, User, PiggyvaultDbContext>
    {
        /* Define a DbSet for each entity of the application */
        
        public PiggyvaultDbContext(DbContextOptions<PiggyvaultDbContext> options)
            : base(options)
        {
        }
    }
}
