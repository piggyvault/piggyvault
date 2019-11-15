using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.Accounts.Dto
{
    /// <summary>
    /// The get accounts async input.
    /// </summary>
    public class GetAccountsAsyncInput
    {
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