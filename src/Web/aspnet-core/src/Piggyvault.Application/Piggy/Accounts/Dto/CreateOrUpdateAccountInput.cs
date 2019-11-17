using System.ComponentModel.DataAnnotations;

namespace Piggyvault.Piggy.Accounts.Dto
{
    public class CreateOrUpdateAccountInput
    {
        /// <summary>
        /// Gets or sets the account.
        /// </summary>
        [Required]
        public virtual AccountEditDto Account { get; set; }
    }
}