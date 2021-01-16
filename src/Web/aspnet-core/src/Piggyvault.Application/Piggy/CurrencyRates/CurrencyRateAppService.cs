using Abp.Auditing;
using Abp.Authorization;
using Abp.Domain.Repositories;
using Flurl;
using Flurl.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Piggyvault.Configuration;
using Piggyvault.Piggy.Currencies;
using Piggyvault.Piggy.CurrencyRates.Dto;
using Piggyvault.Piggy.Transactions;
using Piggyvault.Piggy.Transactions.Dto;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.CurrencyRates
{
    // TODO(abhith): consider caching. Ref: https://aspnetboilerplate.com/Pages/Documents/Caching
    [AbpAuthorize]
    [DisableAuditing]
    public class CurrencyRateAppService : PiggyvaultAppServiceBase, ICurrencyRateAppService
    {
        private readonly IRepository<CurrencyRate, Guid> _currencyRateRepository;
        private readonly PiggySettings _settings;

        public CurrencyRateAppService(IOptions<PiggySettings> settings, IRepository<CurrencyRate, Guid> currencyRateRepository)
        {
            _settings = settings.Value;
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
            var exchangeRate = await GetExchangeRate(input.Account.Currency.Code);
            return Math.Round(input.Amount * exchangeRate, 2);
        }

        public async Task<decimal> GetExchangeRate(string currencyCode)
        {
            try
            {
                var defaultCurrency = SettingManager.GetSettingValue(AppSettingNames.DefaultCurrency);

                if (currencyCode == defaultCurrency)
                {
                    return 1;
                }

                var defaultCurrencyRate = await _currencyRateRepository.GetAll().Where(r => r.Code == defaultCurrency).OrderByDescending(r => r.CreationTime).FirstOrDefaultAsync();

                var inputCurrencyRate = await _currencyRateRepository.GetAll().Where(r => r.Code == currencyCode).OrderByDescending(r => r.CreationTime).FirstOrDefaultAsync();

                return defaultCurrencyRate.Rate / inputCurrencyRate.Rate;
            }
            catch (Exception)
            {
                // TODO: log
                return 1;
            }
        }

        //public async Task<ExchangeRateResult> GetExchangeRate(GetExchangeRateInput input)
        //{
        //    var output = new ExchangeRateResult();

        //    var fromCurrencyRate = await _currencyRateRepository.GetAll().Where(r => r.Code == input.From).OrderByDescending(r => r.CreationTime).FirstOrDefaultAsync();

        //    var toCurrencyRate = await _currencyRateRepository.GetAll().Where(r => r.Code == input.To).OrderByDescending(r => r.CreationTime).FirstOrDefaultAsync();

        //    output.Rate = fromCurrencyRate.Rate / toCurrencyRate.Rate;
        //    output.LastUpdatedTime = fromCurrencyRate.CreationTime;
        //    return output;
        //}

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

        [AbpAllowAnonymous]
        [HttpGet]
        public async Task UpdateCurrencyRates()
        {
            try
            {
                var lastUpdatedDateTime = await _currencyRateRepository.GetAll().OrderByDescending(r => r.CreationTime).FirstOrDefaultAsync();

                // limit update call one per day
                if (lastUpdatedDateTime.CreationTime.AddHours(1) < DateTime.UtcNow)
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
            }
            catch (Exception ex)
            {
                // TODO: log
                throw;
            }
        }
    }
}