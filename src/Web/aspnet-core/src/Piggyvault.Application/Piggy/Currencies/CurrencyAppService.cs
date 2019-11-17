using Abp.Application.Services.Dto;
using Abp.AutoMapper;
using Abp.Domain.Repositories;
using Microsoft.EntityFrameworkCore;
using Piggyvault.Piggy.Currencies.Dto;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.Currencies
{
    public class CurrencyAppService : PiggyvaultAppServiceBase, ICurrencyAppService
    {
        private readonly IRepository<Currency> _currencyRepository;

        public CurrencyAppService(IRepository<Currency> currencyRepository)
        {
            this._currencyRepository = currencyRepository;
        }

        /// <summary>
        /// The get currencies.
        /// </summary>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        public async Task<ListResultDto<CurrencyPreviewDto>> GetCurrencies()
        {
            var output = new ListResultDto<CurrencyPreviewDto>();

            var currencies = await this._currencyRepository.GetAll().OrderBy(c => c.Name).ToListAsync();
            output.Items = currencies.MapTo<List<CurrencyPreviewDto>>();
            return output;
        }
    }
}