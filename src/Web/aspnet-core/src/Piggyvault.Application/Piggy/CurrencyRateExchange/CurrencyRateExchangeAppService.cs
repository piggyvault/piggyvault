using Abp.AutoMapper;
using Piggyvault.Piggy.Transactions;
using Piggyvault.Piggy.Transactions.Dto;
using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.CurrencyRateExchange
{
    public class CurrencyRateExchangeAppService : PiggyvaultAppServiceBase, ICurrencyRateExchangeAppService
    {
        // TODO: Get currency exchange rate from external service like currencylayer.
        /// <summary>
        /// The _aed to inr.
        /// </summary>
        private const decimal _aedToInr = 17.63m;

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
    }
}