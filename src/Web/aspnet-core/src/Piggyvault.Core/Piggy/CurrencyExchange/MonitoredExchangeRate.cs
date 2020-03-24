using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;

namespace Piggyvault.Piggy.CurrencyExchange
{
    [Table("PvMonitoredExchangeRate")]
    public class MonitoredExchangeRate : FullAuditedEntity<Guid>
    {
        [ForeignKey("CurrencyExchangePresetId")]
        public virtual CurrencyExchangePreset CurrencyExchangePreset { get; set; }

        [Required]
        public int CurrencyExchangePresetId { get; set; }

        public bool IsFeatured { get; set; }
    }
}