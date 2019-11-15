namespace Piggyvault.EntityFrameworkCore.Seed.Host
{
    public class InitialHostDbBuilder
    {
        private readonly PiggyvaultDbContext _context;

        public InitialHostDbBuilder(PiggyvaultDbContext context)
        {
            _context = context;
        }

        public void Create()
        {
            new DefaultEditionCreator(_context).Create();
            new DefaultLanguagesCreator(_context).Create();
            new HostRoleAndUserCreator(_context).Create();
            new DefaultSettingsCreator(_context).Create();

            // Piggy
            new InitialCurrenciesCreator(_context).Create();
            new InitialAccountTypeCreator(_context).Create();

            _context.SaveChanges();
        }
    }
}