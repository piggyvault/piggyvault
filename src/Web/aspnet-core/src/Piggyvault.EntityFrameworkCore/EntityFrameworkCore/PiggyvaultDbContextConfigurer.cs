using System.Data.Common;
using Microsoft.EntityFrameworkCore;

namespace Piggyvault.EntityFrameworkCore
{
    public static class PiggyvaultDbContextConfigurer
    {
        public static void Configure(DbContextOptionsBuilder<PiggyvaultDbContext> builder, string connectionString)
        {
            builder.UseSqlServer(connectionString);
        }

        public static void Configure(DbContextOptionsBuilder<PiggyvaultDbContext> builder, DbConnection connection)
        {
            builder.UseSqlServer(connection);
        }
    }
}
