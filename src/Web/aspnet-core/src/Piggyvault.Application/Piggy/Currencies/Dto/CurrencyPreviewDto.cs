using Abp.AutoMapper;
using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.Currencies.Dto
{
    /// <summary>
    /// The currency preview dto.
    /// </summary>
    [AutoMapFrom(typeof(Currency))]
    public class CurrencyPreviewDto
    {
        /// <summary>
        /// Gets or sets the code.
        /// </summary>
        public virtual string Code { get; set; }

        /// <summary>
        /// Gets or sets the id.
        /// </summary>
        public virtual int Id { get; set; }

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