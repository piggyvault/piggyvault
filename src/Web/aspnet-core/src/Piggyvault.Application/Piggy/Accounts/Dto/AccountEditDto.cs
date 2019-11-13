using System.ComponentModel.DataAnnotations;
using System;
using Abp.AutoMapper;

namespace Piggyvault.Piggy.Accounts.Dto
{
    using Currencies.Dto;

    /// <summary>
    /// The account edit dto.
    /// </summary>
    [AutoMap(typeof(Account))]
    public class AccountEditDto
    {
        /// <summary>
        /// Gets or sets the account type.
        /// </summary>
        public AccountTypeEditDto AccountType { get; set; }

        /// <summary>
        /// Gets or sets the account type id.
        /// </summary>
        [Range(1, Int32.MaxValue)]
        public virtual int AccountTypeId { get; set; }

        /// <summary>
        /// Gets or sets the currency.
        /// </summary>
        public CurrencyPreviewDto Currency { get; set; }

        /// <summary>
        /// Gets or sets the currency id.
        /// </summary>
        [Range(1, Int32.MaxValue)]
        public virtual int CurrencyId { get; set; }

        /// <summary>
        /// Gets or sets the id.
        /// </summary>
        public virtual Guid? Id { get; set; }

        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        [MaxLength(Account.MaxNameLength)]
        public virtual string Name { get; set; }

        /// <summary>
        /// Gets or sets the tenant id.
        /// </summary>
        public virtual int TenantId { get; set; }
    }
}