﻿using Abp.AutoMapper;
using System;
using System.Collections.Generic;
using System.Text;

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
        public virtual String Name { get; set; }

        public virtual ICollection<AccountPreviewDto> Accounts { get; set; }
    }
}