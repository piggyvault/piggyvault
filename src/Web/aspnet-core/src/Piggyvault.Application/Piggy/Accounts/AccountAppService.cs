using Abp.Application.Services.Dto;
using Abp.Authorization;
using Abp.AutoMapper;
using Abp.Domain.Repositories;
using Microsoft.EntityFrameworkCore;
using Piggyvault.Piggy.Accounts.Dto;
using Piggyvault.Piggy.Transactions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.Accounts
{
    /// <summary>
    /// The account app service.
    /// </summary>
    [AbpAuthorize]
    public class AccountAppService : PiggyvaultAppServiceBase, IAccountAppService
    {
        /// <summary>
        /// The _account repository.
        /// </summary>
        private readonly IRepository<Account, Guid> _accountRepository;

        /// <summary>
        /// The _account type repository.
        /// </summary>
        private readonly IRepository<AccountType> _accountTypeRepository;

        /// <summary>
        /// The _transaction repository.
        /// </summary>
        private readonly IRepository<Transaction, Guid> _transactionRepository;

        /// <summary>
        /// Initializes a new instance of the <see cref="AccountAppService"/> class.
        /// </summary>
        /// <param name="accountRepository">
        /// The account repository.
        /// </param>
        public AccountAppService(IRepository<Account, Guid> accountRepository, IRepository<AccountType> accountTypeRepository, IRepository<Transaction, Guid> transactionRepository)
        {
            this._accountRepository = accountRepository;
            this._accountTypeRepository = accountTypeRepository;
            this._transactionRepository = transactionRepository;
        }

        /// <summary>
        /// The create or update account.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        [AbpAuthorize]
        public async Task CreateOrUpdateAccount(CreateOrUpdateAccountInput input)
        {
            if (input.Account.Id.HasValue)
            {
                await UpdateAccountAsync(input);
            }
            else
            {
                await CreateAccountAsync(input);
            }
        }

        /// <summary>
        /// The delete account.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        [AbpAuthorize]
        public async Task DeleteAccount(EntityDto<Guid> input)
        {
            await this._accountRepository.DeleteAsync(input.Id);
        }

        /// <summary>
        /// The get account details.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        public async Task<AccountPreviewDto> GetAccountDetails(EntityDto<Guid> input)
        {
            var tenantId = AbpSession.TenantId;
            var account = await _accountRepository.FirstOrDefaultAsync(a => a.Id == input.Id && a.TenantId == tenantId);
            var output = account.MapTo<AccountPreviewDto>();
            output.CurrentBalance = await GetAccountBalanceAsync(input.Id);
            return output;
        }

        public async Task<AccountEditDto> GetAccountForEdit(EntityDto<Guid> input)
        {
            var tenantId = AbpSession.TenantId;
            var account = await _accountRepository.FirstOrDefaultAsync(a => a.Id == input.Id && a.TenantId == tenantId);
            return account.MapTo<AccountEditDto>();
        }

        /// <summary>
        /// The get accounts async.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        public async Task<ListResultDto<AccountPreviewDto>> GetAccountsAsync(GetAccountsAsyncInput input)
        {
            var output = new ListResultDto<AccountPreviewDto>();

            IQueryable<Account> query;

            switch (input.Type)
            {
                case "user":
                    var userId = input.UserId ?? AbpSession.UserId.Value;
                    query = _accountRepository.GetAll()
                        .Include(c => c.CreatorUser)
                        .Include(currency => currency.Currency)
                        .Where(a => a.CreatorUserId == userId);
                    break;

                default:
                    var tenantId = AbpSession.TenantId.Value;
                    query = _accountRepository.GetAll()
                        .Include(c => c.CreatorUser)
                        .Include(currency => currency.Currency)
                        .Where(a => a.TenantId == tenantId);
                    break;
            }

            var accounts = await query.OrderBy(a => a.Name).ToListAsync();

            var accountDtos = accounts.MapTo<List<AccountPreviewDto>>();

            foreach (var account in accountDtos)
            {
                account.CurrentBalance = await GetAccountBalanceAsync(account.Id);
            }

            output.Items = accountDtos;
            return output;
        }

        /// <summary>
        /// The get account types.
        /// </summary>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        [AbpAuthorize]
        public async Task<ListResultDto<AccountTypeEditDto>> GetAccountTypes()
        {
            var accountTypes = await this._accountTypeRepository.GetAll().ToListAsync();
            var output = new ListResultDto<AccountTypeEditDto>
            {
                Items = accountTypes.MapTo<List<AccountTypeEditDto>>()
            };
            return output;
        }

        Task<ListResultDto<AccountTypeEditDto>> IAccountAppService.GetAccountTypes()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// The get tenant accounts async.
        /// </summary>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        public async Task<GetTenantAccountsAsyncOutput> GetTenantAccountsAsync()
        {
            var output = new GetTenantAccountsAsyncOutput();

            var tenantId = AbpSession.TenantId;
            var query = _accountRepository.GetAll()
                .Include(c => c.CreatorUser)
                .Include(currency => currency.Currency)
                .Include(a => a.AccountType)
                .Where(a => a.TenantId == tenantId);

            var accounts = await query.OrderBy(a => a.Name).ToListAsync();

            var userAccounts = new List<Account>();
            var otherMembersAccounts = new List<Account>();

            foreach (var account in accounts)
            {
                if (account.CreatorUserId == AbpSession.UserId)
                {
                    userAccounts.Add(account);
                }
                else
                {
                    otherMembersAccounts.Add(account);
                }
            }

            var userAccountDtos = userAccounts.MapTo<List<AccountPreviewDto>>();
            var otherMembersAccountDtos = otherMembersAccounts.MapTo<List<AccountPreviewDto>>();
            await UpdateAccountsBalanceAsync(userAccountDtos);
            await UpdateAccountsBalanceAsync(otherMembersAccountDtos);

            output.OtherMembersAccounts = new ListResultDto<AccountPreviewDto>(otherMembersAccountDtos);
            output.UserAccounts = new ListResultDto<AccountPreviewDto>(userAccountDtos);
            return output;
        }

        /// <summary>
        /// The get user accounts.
        /// </summary>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        [AbpAuthorize]
        public async Task<ListResultDto<AccountPreviewDto>> GetUserAccounts()
        {
            var output = new ListResultDto<AccountPreviewDto>();
            var accounts = await this._accountRepository.GetAll()
                .Where(a => a.CreatorUserId == AbpSession.UserId)
                .Include(c => c.CreatorUser).OrderBy(a => a.Name)
                .Include(currency => currency.Currency).ToListAsync();
            output.Items = accounts.MapTo<List<AccountPreviewDto>>();
            return output;
        }

        /// <summary>
        /// The create account async.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        private async Task CreateAccountAsync(CreateOrUpdateAccountInput input)
        {
            var account = input.Account.MapTo<Account>();
            account.TenantId = AbpSession.TenantId.Value;
            await this._accountRepository.InsertAsync(account);
        }

        /// <summary>
        /// The get account balance.
        /// </summary>
        /// <param name="accountId">
        /// The account id.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        private async Task<decimal> GetAccountBalanceAsync(Guid accountId)
        {
            decimal output = 0;

            var lastTransasction =
                await
                this._transactionRepository.GetAll()
                    .Where(t => t.AccountId == accountId)
                    .OrderByDescending(t => t.TransactionTime)
                    .ThenByDescending(t => t.CreationTime)
                    .FirstOrDefaultAsync();

            if (lastTransasction != null)
            {
                output = lastTransasction.Balance;
            }

            return output;
        }

        /// <summary>
        /// The update account async.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        private async Task UpdateAccountAsync(CreateOrUpdateAccountInput input)
        {
            var account = await this._accountRepository.FirstOrDefaultAsync(a => a.Id == input.Account.Id);
            input.Account.MapTo(account);
            await this._accountRepository.UpdateAsync(account);
        }

        /// <summary>
        /// The update accounts balance.
        /// </summary>
        /// <param name="userAccountDtos">
        /// The user account dtos.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        private async Task UpdateAccountsBalanceAsync(List<AccountPreviewDto> userAccountDtos)
        {
            foreach (var account in userAccountDtos)
            {
                account.CurrentBalance = await GetAccountBalanceAsync(account.Id);
            }
        }
    }
}