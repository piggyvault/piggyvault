using System;
using System.ComponentModel.DataAnnotations;

namespace Piggyvault.Piggy.Transactions.Dto
{
    /// <summary>
    /// The transfer edit dto.
    /// </summary>
    public class TransferEditDto
    {
        /// <summary>
        /// Gets or sets the account id.
        /// </summary>
        public virtual Guid AccountId { get; set; }

        /// <summary>
        /// Gets or sets the amount.
        /// </summary>
        public virtual decimal Amount { get; set; }

        /// <summary>
        /// Gets or sets the category id.
        /// </summary>
        public virtual Guid CategoryId { get; set; }

        /// <summary>
        /// Gets or sets the description.
        /// </summary>
        [MaxLength(Transaction.MaxDescriptionLength)]
        public virtual string Description { get; set; }

        /// <summary>
        /// Gets or sets the id.
        /// </summary>
        public virtual Guid? Id { get; set; }

        /// <summary>
        /// Gets or sets the to account id.
        /// </summary>
        public virtual Guid ToAccountId { get; set; }

        /// <summary>
        /// Gets or sets the to amount.
        /// </summary>
        public virtual decimal ToAmount { get; set; }

        /// <summary>
        /// Gets or sets the transaction time.
        /// </summary>
        [Required]
        public virtual DateTime TransactionTime { get; set; }
    }
}