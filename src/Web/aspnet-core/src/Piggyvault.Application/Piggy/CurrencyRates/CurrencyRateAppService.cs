using Abp.Auditing;
using Abp.Domain.Repositories;
using Flurl;
using Flurl.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Piggyvault.Configuration;
using Piggyvault.Piggy.Currencies;
using Piggyvault.Piggy.CurrencyRates.Dto;
using Piggyvault.Piggy.Transactions;
using Piggyvault.Piggy.Transactions.Dto;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.CurrencyRateExchange
{
    // TODO: consider caching. Ref: https://aspnetboilerplate.com/Pages/Documents/Caching
    [DisableAuditing]
    public class CurrencyRateAppService : PiggyvaultAppServiceBase, ICurrencyRateAppService
    {
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
        public async Task<decimal> GetAmountInDefaultCurrency(Transaction input)
        {
            var currencyConvertionRate = await GetCurrencyConversionRate(input);
            return Math.Round(input.Amount * currencyConvertionRate, 2);
        }

        public async Task<decimal> GetCurrencyConversionRate(Transaction input)
        {
            try
            {
                var defaultCurrency = SettingManager.GetSettingValue(AppSettingNames.DefaultCurrency);

                if (input.Account.Currency.Code == defaultCurrency)
                {
                    return 1;
                }

                var defaultCurrencyRate = await _currencyRateRepository.GetAll().Where(r => r.Code == defaultCurrency).OrderByDescending(r => r.CreationTime).FirstOrDefaultAsync();

                var inputCurrencyRate = await _currencyRateRepository.GetAll().Where(r => r.Code == input.Account.Currency.Code).OrderByDescending(r => r.CreationTime).FirstOrDefaultAsync();

                return defaultCurrencyRate.Rate / inputCurrencyRate.Rate;
            }
            catch (Exception)
            {
                // TODO: log
                return 1;
            }
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
        public async Task<IEnumerable<TransactionPreviewDto>> GetTransactionsWithAmountInDefaultCurrency(IEnumerable<Transaction> input)
        {
            var output = new List<TransactionPreviewDto>();

            foreach (var transaction in input)
            {
                var dto = ObjectMapper.Map<TransactionPreviewDto>(transaction);

                dto.AmountInDefaultCurrency = await GetAmountInDefaultCurrency(transaction);
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