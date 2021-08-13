using Newtonsoft.Json;
using System.IO;
using System.Linq;

namespace Piggyvault.EntityFrameworkCore.Seed.Host
{
    using Piggyvault.Piggy.Currencies;
    using System;

    public class InitialCurrenciesCreator
    {
        private readonly PiggyvaultDbContext _context;

        public InitialCurrenciesCreator(PiggyvaultDbContext context)
        {
            this._context = context;
        }

        public void Create()
        {
            var currenciesCount = this._context.Currencies.Count();
            if (currenciesCount > 0)
            {
                return;
            }

            try
            {
                using StreamReader r = new StreamReader("Seed/currencies.json");
                string json = r.ReadToEnd();
                dynamic array = JsonConvert.DeserializeObject(json);

                foreach (var item in array)
                {
                    string code = item.code;
                    var currency = this._context.Currencies.FirstOrDefault(c => c.Code == code);
                    if (currency == null)
                    {
                        currency = new Currency()
                        {
                            Symbol = item.symbol,
                            Code = item.code,
                            Name = item.name,
                            SymbolNative = item.symbol_native,
                            DecimalDigits = item.decimal_digits,
                            Rounding = item.rounding,
                            NamePlural = item.name_plural
                        };

                        this._context.Currencies.Add(currency);
                        this._context.SaveChanges();
                    }
                }
            }
            catch (DirectoryNotFoundException ex)
            {
                // ! json file is located under Migrator project hence will fail when seed initiated from other projects.
                Console.WriteLine("Skipping currencies seeding since data source not found.");
            }
        }
    }
}