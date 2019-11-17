using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.Transactions.Dto
{
    /// <summary>
    /// The get type ahead suggestions input.
    /// </summary>
    public class GetTypeAheadSuggestionsInput
    {
        /// <summary>
        /// Gets or sets the query.
        /// </summary>
        public virtual string Query { get; set; }
    }
}