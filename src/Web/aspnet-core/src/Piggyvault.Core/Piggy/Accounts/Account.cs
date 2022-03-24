using Abp.Domain.Entities;
using Abp.Domain.Entities.Auditing;
using Piggyvault.Authorization.Users;
using Piggyvault.Piggy.Currencies;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Piggyvault.Piggy.Accounts
{
    [Table("PvAccount")]
    public class Account : FullAuditedEntity<Guid, User>, IMustHaveTenant
    {
        /// <summary>
        /// The max name length.
        /// </summary>
        public const int MaxNameLength = 50;

        /// <summary>
        /// Gets or sets the account type.
        /// </summary>
        [ForeignKey("AccountTypeId")]
        public virtual AccountType AccountType { get; set; }

        /// <summary>
        /// Gets or sets the account type id.
        /// </summary>
        public virtual int AccountTypeId { get; set; }

        /// <summary>
        /// Gets or sets the currency.
        /// </summary>
        [ForeignKey("CurrencyId")]
        public virtual Currency Currency { get; set; }

        /// <summary>
        /// Gets or sets the currency id.
        /// </summary>
        public virtual int CurrencyId { get; set; }

        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        [Required]
        [MaxLength(MaxNameLength)]
        public virtual string Name { get; set; }

        /// <summary>
        /// Gets or sets the tenant id.
        /// </summary>
        public virtual int TenantId { get; set; }

        public virtual bool IsArchived { get; set; }
    }
}