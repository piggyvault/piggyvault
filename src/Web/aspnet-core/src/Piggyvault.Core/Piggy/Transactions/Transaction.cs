using Abp.Domain.Entities.Auditing;
using Piggyvault.Authorization.Users;
using Piggyvault.Piggy.Accounts;
using Piggyvault.Piggy.Categories;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Piggyvault.Piggy.Transactions
{
    [Table("PvTransaction")]
    public class Transaction : FullAuditedEntity<Guid, User>
    {
        /// <summary>
        /// The max description length.
        /// </summary>
        public const int MaxDescriptionLength = 1000;

        /// <summary>
        /// Gets or sets the account.
        /// </summary>
        [ForeignKey("AccountId")]
        public virtual Account Account { get; set; }

        /// <summary>
        /// Gets or sets the account id.
        /// </summary>
        public Guid AccountId { get; set; }

        /// <summary>
        /// Gets or sets the amount.
        /// </summary>
        public decimal Amount { get; set; }

        /// <summary>
        /// Gets or sets the balance.
        /// </summary>
        public decimal Balance { get; set; }

        /// <summary>
        /// Gets or sets the category.
        /// </summary>
        [ForeignKey("CategoryId")]
        public virtual Category Category { get; set; }

        /// <summary>
        /// Gets or sets the category id.
        /// </summary>
        public Guid CategoryId { get; set; }

        public virtual ICollection<TransactionComment> Comments { get; set; }

        /// <summary>
        /// Gets or sets the description.
        /// </summary>
        [MaxLength(MaxDescriptionLength)]
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether is transferred.
        /// </summary>
        public bool IsTransferred { get; set; }

        /// <summary>
        /// Gets or sets the transaction time.
        /// </summary>
        [Required]
        public DateTime TransactionTime { get; set; }
    }
}