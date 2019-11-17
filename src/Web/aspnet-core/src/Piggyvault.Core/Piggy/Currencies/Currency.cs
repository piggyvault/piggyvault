using Abp.Domain.Entities;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Piggyvault.Piggy.Currencies
{
    [Table("PvCurrency")]
    public class Currency : Entity
    {
        /// <summary>
        /// Gets or sets the code.
        /// </summary>
        [MaxLength(3)]
        public virtual string Code { get; set; }

        /// <summary>
        /// Gets or sets the decimal digits.
        /// </summary>
        public virtual int DecimalDigits { get; set; }

        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        [MaxLength(50)]
        public virtual string Name { get; set; }

        /// <summary>
        /// Gets or sets the name plural.
        /// </summary>
        [MaxLength(50)]
        public virtual string NamePlural { get; set; }

        /// <summary>
        /// Gets or sets the rounding.
        /// </summary>
        public virtual int Rounding { get; set; }

        /// <summary>
        /// Gets or sets the symbol.
        /// </summary>
        [MaxLength(10)]
        public virtual string Symbol { get; set; }

        /// <summary>
        /// Gets or sets the symbol native.
        /// </summary>
        [MaxLength(10)]
        public virtual string SymbolNative { get; set; }
    }
}