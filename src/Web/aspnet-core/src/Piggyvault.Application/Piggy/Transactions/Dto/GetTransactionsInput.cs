using System;

namespace Piggyvault.Piggy.Transactions.Dto
{
    /// <summary>
    /// The get transactions input.
    /// </summary>
    public class GetTransactionsInput
    {
        /// <summary>
        /// Gets or sets the account id.
        /// </summary>
        public Guid? AccountId { get; set; }

        public Guid? CategoryId { get; set; }

        /// <summary>
        /// Gets or sets the end date.
        /// </summary>
        public DateTime? EndDate { get; set; }

        /// <summary>
        /// search
        /// </summary>
        public string Query { get; set; }

        /// <summary>
        /// Gets or sets the start date.
        /// </summary>
        public DateTime? StartDate { get; set; }

        /// <summary>
        /// Gets or sets the type.
        /// </summary>
        public string Type { get; set; }

        /// <summary>
        /// Gets or sets the user id.
        /// </summary>
        public long? UserId { get; set; }
    }
}