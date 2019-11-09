using Abp.AutoMapper;

namespace Piggyvault.Piggy.Accounts.Dto
{
    /// <summary>
    /// The account type edit dto.
    /// </summary>
    [AutoMapFrom(typeof(AccountType))]
    public class AccountTypeEditDto
    {
        /// <summary>
        /// Gets or sets the id.
        /// </summary>
        public virtual int Id { get; set; }

        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        public virtual string Name { get; set; }
    }
}