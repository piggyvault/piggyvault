using Abp.AutoMapper;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Piggyvault.Piggy.Accounts.Dto
{
    /// <summary>
    /// The account edit dto.
    /// </summary>
    [AutoMap(typeof(Account))]
    public class AccountEditDto
    {
        /// <summary>
        /// Gets or sets the account type id.
        /// </summary>
        [Range(1, Int32.MaxValue)]
        public virtual int AccountTypeId { get; set; }

        /// <summary>
        /// Gets or sets the currency id.
        /// </summary>
        [Range(1, Int32.MaxValue)]
        public virtual int CurrencyId { get; set; }

        /// <summary>
        /// Gets or sets the id.
        /// </summary>
        public virtual Guid? Id { get; set; }

        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        [MaxLength(Account.MaxNameLength)]
        public virtual string Name { get; set; }
    }
}