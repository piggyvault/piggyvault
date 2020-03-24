using Microsoft.EntityFrameworkCore;
using Abp.Zero.EntityFrameworkCore;
using Piggyvault.Authorization.Roles;
using Piggyvault.Authorization.Users;
using Piggyvault.MultiTenancy;
using Piggyvault.Piggy.Accounts;
using Piggyvault.Piggy.Categories;
using Piggyvault.Piggy.Currencies;
using Piggyvault.Piggy.CurrencyExchange;
using Piggyvault.Piggy.Transactions;

namespace Piggyvault.EntityFrameworkCore
{
    public class PiggyvaultDbContext : AbpZeroDbContext<Tenant, Role, User, PiggyvaultDbContext>
    {
        /* Define a DbSet for each entity of the application */

        public PiggyvaultDbContext(DbContextOptions<PiggyvaultDbContext> options)
            : base(options)
        {
        }

        public virtual DbSet<Account> Accounts { get; set; }
        public virtual DbSet<AccountType> AccountTypes { get; set; }

        public virtual DbSet<Category> Categories { get; set; }

        public virtual DbSet<Currency> Currencies { get; set; }
        public virtual DbSet<CurrencyExchangePreset> CurrencyExchangePresets { get; set; }
        public virtual DbSet<CurrencyExchangeRate> CurrencyExchangeRates { get; set; }
        public virtual DbSet<CurrencyRate> CurrencyRates { get; set; }
        public virtual DbSet<MonitoredExchangeRate> MonitoredExchangeRates { get; set; }
        public virtual DbSet<TransactionComment> TransactionComments { get; set; }
        public virtual DbSet<Transaction> Transactions { get; set; }
    }
}