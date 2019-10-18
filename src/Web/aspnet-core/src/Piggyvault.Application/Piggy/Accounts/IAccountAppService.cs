using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Piggyvault.Piggy.Accounts.Dto;
using System;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.Accounts
{
    public interface IAccountAppService : IApplicationService
    {
        /// <summary>
        /// The create or update account.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        Task CreateOrUpdateAccount(CreateOrUpdateAccountInput input);

        /// <summary>
        /// The delete account.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        Task DeleteAccount(EntityDto<Guid> input);

        Task<AccountPreviewDto> GetAccountDetails(EntityDto<Guid> input);

        Task<AccountEditDto> GetAccountForEdit(EntityDto<Guid> input);

        Task<ListResultDto<AccountPreviewDto>> GetAccountsAsync(GetAccountsAsyncInput input);

        Task<GetTenantAccountsAsyncOutput> GetTenantAccountsAsync();

        /// <summary>
        /// The get user accounts.
        /// </summary>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        Task<ListResultDto<AccountPreviewDto>> GetUserAccounts();

        #region Account Types

        /// <summary>
        /// The get account types.
        /// </summary>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        Task<ListResultDto<AccountTypeEditDto>> GetAccountTypes();

        // Task<AccountSummaryOutput> GetAccountSummary(GetAccountSummaryInput input);

        #endregion Account Types
    }
}