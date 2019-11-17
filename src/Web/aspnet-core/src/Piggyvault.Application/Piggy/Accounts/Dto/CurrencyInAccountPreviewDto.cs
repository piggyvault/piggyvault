using Abp.AutoMapper;
using Piggyvault.Piggy.Currencies;
using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.Accounts.Dto
{
    [AutoMapFrom(typeof(Currency))]
    public class CurrencyInAccountPreviewDto
    {
        public virtual string Code { get; set; }

        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        public virtual string Name { get; set; }

        /// <summary>
        /// Gets or sets the symbol.
        /// </summary>
        public virtual string Symbol { get; set; }

        /// <summary>
        /// Gets or sets the symbol native.
        /// </summary>
        public virtual string SymbolNative { get; set; }
    }
}