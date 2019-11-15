using System.ComponentModel.DataAnnotations.Schema;
using System.Collections.Generic;
using Abp.Domain.Entities;
using System;

namespace Piggyvault.Piggy.Accounts
{
    [Table("PvAccountType")]
    public class AccountType : Entity
    {
        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        public virtual String Name { get; set; }

        public virtual ICollection<Account> Accounts { get; set; }
    }
}