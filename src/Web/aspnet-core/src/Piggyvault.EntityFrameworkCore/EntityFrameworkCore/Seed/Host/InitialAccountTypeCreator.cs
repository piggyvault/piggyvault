using Piggyvault.Piggy.Accounts;
using System.Linq;

namespace Piggyvault.EntityFrameworkCore.Seed.Host
{
    public class InitialAccountTypeCreator
    {
        private readonly PiggyvaultDbContext _context;

        public InitialAccountTypeCreator(PiggyvaultDbContext context)
        {
            this._context = context;
        }

        public void Create()
        {
            var accountTypesCount = this._context.AccountTypes.Count();
            if (accountTypesCount == 0)
            {
                var accountType = new AccountType()
                {
                    Name = "Cash"
                };

                this._context.AccountTypes.Add(accountType);
                _context.SaveChanges();

                accountType = new AccountType()
                {
                    Name = "Savings"
                };

                this._context.AccountTypes.Add(accountType);
                _context.SaveChanges();

                accountType = new AccountType()
                {
                    Name = "Current Deposit"
                };

                this._context.AccountTypes.Add(accountType);
                _context.SaveChanges();
            }
        }
    }
}