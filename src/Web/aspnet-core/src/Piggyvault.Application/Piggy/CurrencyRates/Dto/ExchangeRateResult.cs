using System;

namespace Piggyvault.Piggy.CurrencyRates.Dto
{
    public class ExchangeRateResult
    {
        public DateTime LastUpdatedTime { get; set; }
        public decimal Rate { get; set; }
    }
}