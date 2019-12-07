using Abp.Application.Services;
using Piggyvault.Piggy.Transactions;
using Piggyvault.Piggy.Transactions.Dto;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.CurrencyRateExchange
{
    public interface ICurrencyRateAppService : IApplicationService
    {
        Task<decimal> GetAmountInDefaultCurrency(Transaction input);

        Task<decimal> GetCurrencyConversionRate(Transaction input);

        Task<IEnumerable<TransactionPreviewDto>> GetTransactionsWithAmountInDefaultCurrency(IEnumerable<Transaction> input);

        Task UpdateCurrencyRates();
    }
}