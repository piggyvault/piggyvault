using System.Collections.Generic;
using System.Threading.Tasks;
using Abp.Application.Services;
using Piggyvault.Piggy.Transactions;
using Piggyvault.Piggy.Transactions.Dto;

namespace Piggyvault.Piggy.CurrencyRates
{
    public interface ICurrencyRateAppService : IApplicationService
    {
        Task<decimal> GetAmountInDefaultCurrency(Transaction input);

        Task<decimal> GetExchangeRate(string currencyCode);

        Task<IEnumerable<TransactionPreviewDto>> GetTransactionsWithAmountInDefaultCurrency(IEnumerable<Transaction> input);

        Task UpdateCurrencyRates();
    }
}