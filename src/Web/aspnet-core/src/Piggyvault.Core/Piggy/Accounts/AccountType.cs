using Abp.Domain.Entities;
using System.ComponentModel.DataAnnotations.Schema;

namespace Piggyvault.Piggy.Accounts
{
    [Table("PvAccountType")]
    public class AccountType : Entity
    {
        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        public virtual string Name { get; set; }
    }
}