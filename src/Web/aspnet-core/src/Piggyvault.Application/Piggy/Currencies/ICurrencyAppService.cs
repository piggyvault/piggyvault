using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Piggyvault.Piggy.Currencies.Dto;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.Currencies
{
    /// <summary>
    /// The CurrencyAppService interface.
    /// </summary>
    public interface ICurrencyAppService : IApplicationService
    {
        /// <summary>
        /// The get currencies.
        /// </summary>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        Task<ListResultDto<CurrencyPreviewDto>> GetCurrencies();
    }
}