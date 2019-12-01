using Abp.Auditing;
using Abp.AutoMapper;
using Abp.Domain.Repositories;
using Flurl;
using Flurl.Http;
using Microsoft.AspNetCore.Mvc;
using Piggyvault.Piggy.Currencies;
using Piggyvault.Piggy.CurrencyRates.Dto;
using Piggyvault.Piggy.Transactions;
using Piggyvault.Piggy.Transactions.Dto;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.CurrencyRateExchange
{
    [DisableAuditing]
    public class CurrencyRateAppService : PiggyvaultAppServiceBase, ICurrencyRateAppService
    {
        // TODO: Get currency exchange rate from external service like currencylayer.
        /// <summary>
        /// The _aed to inr.
        /// </summary>
        private const decimal _aedToInr = 17.63m;

        private readonly IRepository<CurrencyRate, Guid> _currencyRateRepository;
        private readonly PiggySettings _settings;

        public CurrencyRateAppService(PiggySettings settings, IRepository<CurrencyRate, Guid> currencyRateRepository)
        {
            _settings = settings;
            _currencyRateRepository = currencyRateRepository;
        }

        /// <summary>
        /// The get amount in default currency.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="decimal"/>.
        /// </returns>
        public decimal GetAmountInDefaultCurrency(Transaction input)
        {
            var currencyConvertionRate = GetCurrencyConversionRate(input);
            return Math.Round(input.Amount * currencyConvertionRate, 2);
        }

        public decimal GetCurrencyConversionRate(Transaction input)
        {
            decimal currencyConversionRate;
            switch (input.Account.Currency.Code)
            {
                case "INR":
                    currencyConversionRate = 1;
                    break;

                case "AED":
                    currencyConversionRate = _aedToInr;
                    break;

                default:
                    currencyConversionRate = 1;
                    break;
            }
            return currencyConversionRate;
        }

        /// <summary>
        /// The get transactions with amount in default currency.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="IEnumerable"/>.
        /// </returns>
        public IEnumerable<TransactionPreviewDto> GetTransactionsWithAmountInDefaultCurrency(IEnumerable<Transaction> input)
        {
            var output = new List<TransactionPreviewDto>();

            foreach (var transaction in input)
            {
                var dto = transaction.MapTo<TransactionPreviewDto>();
                dto.AmountInDefaultCurrency = GetAmountInDefaultCurrency(transaction);
                output.Add(dto);
            }

            return output;
        }

        [HttpGet]
        public async Task UpdateCurrencyRates()
        {
            try
            {
                var quote = await "http://data.fixer.io/api/latest"
                .SetQueryParams(new
                {
                    access_key = _settings.Fixer.ApiKey
                }).GetJsonAsync<Quote>();

                foreach (var rate in quote.Rates)
                {
                    await _currencyRateRepository.InsertAsync(new CurrencyRate { Code = rate.Key, Rate = rate.Value });
                }
            }
            catch (Exception ex)
            {
                // TODO: log
                throw;
            }
        }
    }
}