using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;
using Abp.Domain.Entities.Auditing;

namespace Piggyvault.Piggy.CurrencyExchange
{
    [Table("PvCurrencyExchangeRate")]
    public class CurrencyExchangeRate : Entity<Guid>, IHasCreationTime
    {
        public DateTime CreationTime { get; set; }

        [ForeignKey("CurrencyExchangePresetId")]
        public virtual CurrencyExchangePreset CurrencyExchangePreset { get; set; }

        [Required]
        public int CurrencyExchangePresetId { get; set; }

        [Required]
        [Column(TypeName = "decimal(18, 6)")]
        public decimal Rate { get; set; }
    }
}