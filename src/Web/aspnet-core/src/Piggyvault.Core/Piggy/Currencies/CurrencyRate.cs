using Abp.Domain.Entities;
using Abp.Domain.Entities.Auditing;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Piggyvault.Piggy.Currencies
{
    [Table("PvCurrencyRate")]
    public class CurrencyRate : Entity<Guid>, IHasCreationTime
    {
        /// <summary>
        /// Gets or sets the code.
        /// </summary>
        [Required]
        [MaxLength(3)]
        public virtual string Code { get; set; }

        [Required]
        public DateTime CreationTime { get; set; }

        [Required]
        [Column(TypeName = "decimal(18, 6)")]
        public decimal Rate { get; set; }
    }
}