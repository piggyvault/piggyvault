using Abp.Application.Services;
using Piggyvault.Piggy.Transactions;
using Piggyvault.Piggy.Transactions.Dto;
using System.Collections.Generic;

namespace Piggyvault.Piggy.CurrencyRateExchange
{
    public interface ICurrencyRateExchangeAppService : IApplicationService
    {
        decimal GetAmountInDefaultCurrency(Transaction input);

        decimal GetCurrencyConversionRate(Transaction input);

        IEnumerable<TransactionPreviewDto> GetTransactionsWithAmountInDefaultCurrency(IEnumerable<Transaction> input);
    }
}