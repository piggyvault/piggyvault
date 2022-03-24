using Abp.AutoMapper;
using System;

namespace Piggyvault.Piggy.Accounts.Dto
{
    /// <summary>
    /// The account preview dto.
    /// </summary>
    [AutoMapFrom(typeof(Account))]
    public class AccountPreviewDto
    {
        /// <summary>
        /// Gets or sets the account type.
        /// </summary>
        public virtual string AccountType { get; set; }

        /// <summary>
        /// Gets or sets the account holder.
        /// </summary>
        public virtual string CreatorUserName { get; set; }

        /// <summary>
        /// Gets or sets the currency.
        /// </summary>
        public virtual CurrencyInAccountPreviewDto Currency { get; set; }

        /// <summary>
        /// Gets or sets the current balance.
        /// </summary>
        public virtual decimal CurrentBalance { get; set; }

        /// <summary>
        /// Gets or sets the id.
        /// </summary>
        public virtual Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        public virtual string Name { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether own account.
        /// </summary>
        public virtual bool OwnAccount { get; set; }

        public bool IsArchived { get; set; }

    }
}