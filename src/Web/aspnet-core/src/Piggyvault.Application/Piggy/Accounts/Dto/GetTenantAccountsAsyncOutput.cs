using Abp.Application.Services.Dto;
using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.Accounts.Dto
{
    public class GetTenantAccountsAsyncOutput
    {
        /// <summary>
        /// Gets or sets the other members accounts.
        /// </summary>
        public ListResultDto<AccountPreviewDto> OtherMembersAccounts { get; set; }

        /// <summary>
        /// Gets or sets the user accounts.
        /// </summary>
        public ListResultDto<AccountPreviewDto> UserAccounts { get; set; }
    }
}