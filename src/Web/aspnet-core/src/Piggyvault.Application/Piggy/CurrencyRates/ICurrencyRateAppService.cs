using Abp.Application.Services;
using Microsoft.AspNetCore.Mvc;
using Piggyvault.Piggy.Transactions;
using Piggyvault.Piggy.Transactions.Dto;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.CurrencyRateExchange
{
    public interface ICurrencyRateAppService : IApplicationService
    {
        decimal GetAmountInDefaultCurrency(Transaction input);

        decimal GetCurrencyConversionRate(Transaction input);

        IEnumerable<TransactionPreviewDto> GetTransactionsWithAmountInDefaultCurrency(IEnumerable<Transaction> input);

        Task UpdateCurrencyRates();
    }
}