using Abp.AutoMapper;
using System;
using System.ComponentModel.DataAnnotations;

namespace Piggyvault.Piggy.Accounts.Dto
{
    /// <summary>
    /// The account edit dto.
    /// </summary>
    [AutoMap(typeof(Account))]
    public class AccountEditDto
    {
        /// <summary>
        /// Gets or sets the account type id.
        /// </summary>
        [Required]
        [Range(1, int.MaxValue)]
        public virtual int AccountTypeId { get; set; }

        /// <summary>
        /// Gets or sets the currency id.
        /// </summary>
        [Required]
        [Range(1, int.MaxValue)]
        public virtual int CurrencyId { get; set; }

        /// <summary>
        /// Gets or sets the id.
        /// </summary>
        public virtual Guid? Id { get; set; }

        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        [Required]
        [MaxLength(Account.MaxNameLength)]
        public virtual string Name { get; set; }

        public virtual bool IsArchived { get; set; }

    }
}