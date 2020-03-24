using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;
using Abp.Domain.Entities.Auditing;
using Piggyvault.Piggy.Currencies;

namespace Piggyvault.Piggy.CurrencyExchange
{
    [Table("PvCurrencyExchangePreset")]
    public class CurrencyExchangePreset : Entity<int>, IHasCreationTime
    {
        public DateTime CreationTime { get; set; }

        [ForeignKey("FromCurrencyId")]
        public virtual Currency FromCurrency { get; set; }

        [Required]
        public int FromCurrencyId { get; set; }

        [ForeignKey("ToCurrencyId")]
        public virtual Currency ToCurrency { get; set; }

        [Required]
        public int ToCurrencyId { get; set; }
    }
}