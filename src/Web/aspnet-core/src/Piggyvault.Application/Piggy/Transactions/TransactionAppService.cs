using Abp.Authorization;
using Abp.AutoMapper;
using Abp.BackgroundJobs;
using Abp.Domain.Repositories;
using Abp.Extensions;
using Code.Library.Extensions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Piggyvault.Piggy.Accounts;
using Piggyvault.Piggy.CurrencyRates;
using Piggyvault.Piggy.Notifications;
using Piggyvault.Piggy.Notifications.Dto;
using Piggyvault.Piggy.Transactions.Dto;
using Piggyvault.Sessions;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.Transactions
{
    /// <summary>
    /// The transaction app service.
    /// </summary>
    [AbpAuthorize]
    public class TransactionAppService : PiggyvaultAppServiceBase, ITransactionAppService
    {
        /// <summary>
        /// The _account repository.
        /// </summary>
        private readonly IRepository<Account, Guid> _accountRepository;

        private readonly IBackgroundJobManager _backgroundJobManager;
        private readonly ICurrencyRateAppService _currencyRateExchangeService;
        private readonly ISessionAppService _sessionAppService;
        private readonly PiggySettings _settings;
        private readonly IRepository<TransactionComment, Guid> _transactionCommentRepository;
        private readonly IRepository<Transaction, Guid> _transactionRepository;

        public TransactionAppService(IRepository<Transaction, Guid> transactionRepository, IRepository<Account, Guid> accountRepository,
            ISessionAppService sessionAppService, ICurrencyRateAppService currencyRateExchangeService,
            IRepository<TransactionComment, Guid> transactionCommentRepository, IOptions<PiggySettings> settings, IBackgroundJobManager backgroundJobManager)
        {
            _transactionRepository = transactionRepository;
            _accountRepository = accountRepository;
            _sessionAppService = sessionAppService;
            _currencyRateExchangeService = currencyRateExchangeService;
            _transactionCommentRepository = transactionCommentRepository;
            _settings = settings.Value;
            _backgroundJobManager = backgroundJobManager;
        }

        /// <summary>
        /// The copy transaction async.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        public async Task CopyTransactionAsync(Abp.Application.Services.Dto.EntityDto<Guid> input)
        {
            var baseTransaction = await this._transactionRepository.FirstOrDefaultAsync(t => t.Id == input.Id);
            var transctionDto = new TransactionEditDto();
            baseTransaction.MapTo(transctionDto);
            transctionDto.Id = null;
            transctionDto.TransactionTime = DateTime.UtcNow;

            await CreateOrUpdateTransaction(transctionDto);
        }

        [AbpAuthorize]
        public async Task CreateOrUpdateTransaction(TransactionEditDto input)
        {
            if (input.Id.HasValue)
            {
                await UpdateTransactionAsync(input);
            }
            else
            {
                await InsertTransactionAsync(input);
            }
        }

        public async Task CreateOrUpdateTransactionCommentAsync(TransactionCommentEditDto input)
        {
            if (input.Id.HasValue)
            {
                await UpdateTransactionCommentAsync(input);
            }
            else
            {
                await CreateTransactionCommentAsync(input);
            }
        }

        public async Task DeleteTransaction(Abp.Application.Services.Dto.EntityDto<Guid> input)
        {
            var tenantId = AbpSession.TenantId;
            var transaction = await _transactionRepository.FirstOrDefaultAsync(t => t.Id == input.Id && t.Account.TenantId == tenantId);
            if (transaction == null)
            {
                throw new AbpAuthorizationException("You are not authorized to perform the requested action");
            }
            await _transactionRepository.DeleteAsync(input.Id);
            await CurrentUnitOfWork.SaveChangesAsync();
            await UpdateTransactionsBalanceInAccountAsync(transaction.AccountId);
        }

        public async Task<GetTransactionSummaryOutput> GetSummary(GetTransactionSummaryInput input)
        {
            var startDate = DateTime.Today.FirstDayOfMonth();
            var endDate = startDate.AddMonths(1).AddTicks(-1);

            var tenantId = AbpSession.TenantId;

            var output = new GetTransactionSummaryOutput();

            var tenantTransactions = await
                  _transactionRepository.GetAll()
                      .Include(t => t.Account)
                        .ThenInclude(account => account.Currency)
                      .Where(t => t.Account.TenantId == tenantId && t.TransactionTime > startDate && t.TransactionTime < endDate && !t.IsTransferred).ToListAsync();

            decimal tenantNetWorth = 0;
            decimal tenantIncome = 0;
            decimal tenantExpense = 0;

            decimal userNetWorth = 0;
            decimal userIncome = 0;
            decimal userExpense = 0;

            decimal accountIncome = 0;
            decimal accountExpense = 0;

            foreach (var transaction in tenantTransactions)
            {
                var currencyConversionRate = await _currencyRateExchangeService.GetExchangeRate(transaction.Account.Currency.Code);

                if (transaction.Amount > 0)
                {
                    tenantIncome += transaction.Amount * currencyConversionRate;

                    if (transaction.CreatorUserId == AbpSession.UserId)
                    {
                        userIncome += transaction.Amount * currencyConversionRate;
                    }

                    if (input.AccountId.HasValue && transaction.AccountId == input.AccountId)
                    {
                        accountIncome += transaction.Amount * currencyConversionRate;
                    }
                }
                else
                {
                    tenantExpense += transaction.Amount * currencyConversionRate;
                    if (transaction.CreatorUserId == AbpSession.UserId)
                    {
                        userExpense += transaction.Amount * currencyConversionRate;
                    }

                    if (input.AccountId.HasValue && transaction.AccountId == input.AccountId)
                    {
                        accountExpense += transaction.Amount * currencyConversionRate;
                    }
                }
            }

            output.TenantExpense = tenantExpense;
            output.TenantIncome = tenantIncome;
            // expense is -ve
            output.TenantSaved = tenantIncome + tenantExpense;

            output.UserExprense = userExpense;
            output.UserIncome = userIncome;
            // expense is -ve
            output.UserSaved = userIncome + userExpense;

            output.AccountExpense = accountExpense;
            output.AccountIncome = accountIncome;
            output.AccountSaved = accountIncome + accountExpense;

            // net worth calc

            var tenantAccounts = await _accountRepository.GetAll().Where(a => a.TenantId == tenantId).ToListAsync();

            foreach (var account in tenantAccounts)
            {
                var lastTransaction = await _transactionRepository.GetAll()
                    .Include(transaction => transaction.Account)
                        .ThenInclude(account => account.Currency)
                    .Where(t => t.AccountId == account.Id)
                    .OrderByDescending(t => t.TransactionTime)
                    .ThenByDescending(t => t.CreationTime).FirstOrDefaultAsync();

                if (lastTransaction != null)
                {
                    decimal currencyConversionRate = await _currencyRateExchangeService.GetExchangeRate(lastTransaction.Account.Currency.Code);

                    var convertedAmount = lastTransaction.Balance * currencyConversionRate;

                    tenantNetWorth += convertedAmount;

                    if (lastTransaction.CreatorUserId == AbpSession.UserId)
                    {
                        userNetWorth += convertedAmount;
                    }
                }
            }

            output.TenantNetWorth = tenantNetWorth;
            output.UserNetWorth = userNetWorth;
            output.CurrencySymbol = "₹";

            int networthPercentage = 0;

            int incomePercentage = 0;

            int expensePercentage = 0;

            int savedPercentage = 0;

            if (input.AccountId.HasValue)
            {
                // divide by zero case handled
                if (tenantIncome != 0) incomePercentage = (int)((accountIncome / tenantIncome) * 100);
                if (tenantExpense != 0) expensePercentage = (int)((accountExpense / tenantExpense) * 100);
                if (tenantNetWorth != 0) networthPercentage = (int)((userNetWorth / tenantNetWorth) * 100);
                if (output.TenantSaved != 0) savedPercentage = (int)((output.AccountSaved / output.TenantSaved) * 100);
            }
            else
            {
                if (tenantIncome != 0) incomePercentage = (int)((userIncome / tenantIncome) * 100);
                if (tenantExpense != 0) expensePercentage = (int)((userExpense / tenantExpense) * 100);
                if (tenantNetWorth != 0) networthPercentage = (int)((userNetWorth / tenantNetWorth) * 100);
                if (output.TenantSaved != 0) savedPercentage = (int)((output.UserSaved / output.TenantSaved) * 100);
            }

            output.NetWorthPercentage = $"{networthPercentage}%";
            output.IncomePercentage = $"{incomePercentage}%";
            output.ExpensePercentage = $"{expensePercentage}%";
            output.SavedPercentage = $"{savedPercentage}%";

            output.TotalFamilyTransactionsCount = await _transactionRepository.CountAsync(t => t.Account.TenantId == tenantId);

            return output;
        }

        public async Task<Abp.Application.Services.Dto.ListResultDto<TransactionCommentPreviewDto>> GetTransactionComments(Abp.Application.Services.Dto.EntityDto<Guid> input)
        {
            var transctionComments = await _transactionCommentRepository.GetAll()
                .Include(c => c.CreatorUser)
                .Where(c => c.TransactionId == input.Id)
                .OrderBy(c => c.CreationTime)
                .AsNoTracking()
                .ToListAsync();

            return new Abp.Application.Services.Dto.ListResultDto<TransactionCommentPreviewDto>(transctionComments.MapTo<List<TransactionCommentPreviewDto>>());
        }

        public async Task<TransactionEditDto> GetTransactionForEdit(Abp.Application.Services.Dto.EntityDto<Guid> input)
        {
            var tenantId = AbpSession.TenantId;
            var transaction = await
                _transactionRepository.FirstOrDefaultAsync(t => t.Id == input.Id && t.Account.TenantId == tenantId);
            return transaction.MapTo<TransactionEditDto>();
        }

        /// <summary>
        /// The get transactions async.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        public async Task<Abp.Application.Services.Dto.PagedResultDto<TransactionPreviewDto>> GetTransactionsAsync(GetTransactionsInput input)
        {
            var output = new Abp.Application.Services.Dto.PagedResultDto<TransactionPreviewDto>();

            IQueryable<Transaction> query;

            var tenantId = AbpSession.TenantId;
            switch (input.Type)
            {
                case "tenant":
                    query = _transactionRepository.GetAll()
                                        .Include(t => t.Account)
                                            .ThenInclude(account => account.Currency)
                                        .Include(t => t.Category)
                                        .Where(t => t.Account.TenantId == tenantId);
                    break;

                case "user":
                    var userId = input.UserId ?? AbpSession.UserId;
                    query = _transactionRepository.GetAll()
                    .Include(t => t.Account)
                        .ThenInclude(account => account.Currency)
                    .Include(t => t.Category)
                    .Where(t => t.CreatorUserId == userId);
                    break;

                case "account":
                    // TODO : NULL | Account owner tenant validation
                    query = _transactionRepository.GetAll()
                    .Include(t => t.Account)
                        .ThenInclude(account => account.Currency)
                    .Include(t => t.Category)
                    .Where(t => t.AccountId == input.AccountId.Value);
                    break;

                case "category":
                    query = _transactionRepository.GetAll()
                        .Include(t => t.Account)
                        .ThenInclude(account => account.Currency)
                        .Include(t => t.Category)
                        .Where(t => t.CategoryId == input.CategoryId.Value);
                    break;

                default:
                    query = _transactionRepository.GetAll()
                    .Include(t => t.Account)
                        .ThenInclude(account => account.Currency)
                    .Include(t => t.Category)
                    .Where(t => t.Account.TenantId == tenantId);
                    break;
            }

            // transaction period
            DateTime startDate;
            DateTime endDate;

            if (input.StartDate.HasValue && input.EndDate.HasValue)
            {
                startDate = input.StartDate.Value.Date;
                endDate = input.EndDate.Value.Date.AddDays(1).AddTicks(-1);
            }
            else
            {
                startDate = DateTime.Today.FirstDayOfMonth();
                endDate = startDate.AddMonths(1).AddTicks(-1);
            }

            // search
            if (!string.IsNullOrWhiteSpace(input.Query))
            {
                query = query.Where(t => t.Description.Contains(input.Query));
            }

            var transactions = await query.Include(c => c.CreatorUser)
                                        .Where(t => t.TransactionTime >= startDate && t.TransactionTime <= endDate)
                                        .OrderByDescending(t => t.TransactionTime)
                                        .ThenByDescending(t => t.CreationTime)
                                        .ToListAsync();

            output.Items = (await _currencyRateExchangeService.GetTransactionsWithAmountInDefaultCurrency(transactions)).ToList();

            return output;
        }

        public async Task<Abp.Application.Services.Dto.ListResultDto<string>> GetTypeAheadSuggestionsAsync(GetTypeAheadSuggestionsInput input)
        {
            var descriptionList = await _transactionRepository.GetAll()
                    .Where(t => t.Description.Contains(input.Query) && t.CreatorUserId == AbpSession.UserId)
                    .GroupBy(t => t.Description)
                    .Select(t => t.FirstOrDefault().Description).ToListAsync();

            return new Abp.Application.Services.Dto.ListResultDto<string>(descriptionList);
        }

        Task<Abp.Application.Services.Dto.ListResultDto<string>> ITransactionAppService.GetTypeAheadSuggestionsAsync(GetTypeAheadSuggestionsInput input)
        {
            throw new NotImplementedException();
        }

        public async Task ReCalculateAllAccountsTransactionBalanceOfUserAsync()
        {
            var userId = AbpSession.UserId;
            var userAccounts = await _accountRepository.GetAll().Where(a => a.CreatorUserId == userId).ToListAsync();

            foreach (var account in userAccounts)
            {
                await UpdateTransactionsBalanceInAccountAsync(account.Id);
            }
        }

        /// <summary>
        /// The send notification async.
        /// </summary>
        /// <param name="transactionId">
        /// The transaction id.
        /// </param>
        /// <param name="notificationType"></param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        public async Task SendNotificationAsync(Guid transactionId, NotificationTypes notificationType)
        {
            var transaction = await _transactionRepository.GetAll()
                .Include(t => t.Account)
                    .ThenInclude(account => account.Currency)
                .Include(t => t.Category)
                .Include(t => t.CreatorUser)
                .Where(t => t.Id == transactionId)
                .FirstOrDefaultAsync();

            var transactionPreviewDto = ObjectMapper.Map<TransactionPreviewDto>(transaction);

            var contentHeading = transaction.Amount > 0 ? "🐷 Inflow" : "🔥 Outflow";
            var notificationHeadingFromOrTo = transaction.Amount > 0 ? "to" : "from";
            var amount = transaction.Amount > 0 ? transaction.Amount : -transaction.Amount;
            contentHeading += $" of {transaction.Account.Currency.Symbol} {amount} {notificationHeadingFromOrTo} {transaction.CreatorUser.UserName.ToPascalCase()}'s {transaction.Account.Name}";

            var notificationHeading = notificationType switch
            {
                NotificationTypes.NewTransaction => $"New Transaction By {transaction.CreatorUser.UserName.ToPascalCase()}",
                NotificationTypes.UpdateTransaction => $"Transaction Updated By {transaction.CreatorUser.UserName.ToPascalCase()}",
                _ => "New Activity",
            };

            var currentUser = await _sessionAppService.GetCurrentLoginInformations();

            await _backgroundJobManager.EnqueueAsync<SendPushNotificationJob, SendPushNotificationJobArgs>(
                new SendPushNotificationJobArgs
                {
                    Contents = $"{contentHeading}{Environment.NewLine}{transaction.Description}",
                    Data = GetTransactionDataInDictionary(transactionPreviewDto),
                    Headings = notificationHeading,
                    ChannelId = notificationType == NotificationTypes.NewTransaction
                        ? _settings.OneSignal.Channels.NewTransaction
                        : _settings.OneSignal.Channels.UpdateTransaction,
                    TenancyName = currentUser.Tenant.TenancyName.Trim().ToLowerInvariant()
                });
        }

        public async Task TransferAsync(TransferEditDto input)
        {
            // make sure expense
            if (input.Amount > 0)
            {
                input.Amount *= -1;
            }

            var sentTransaction = new TransactionEditDto()
            {
                Amount = input.Amount,
                AccountId = input.AccountId,
                CategoryId = input.CategoryId,
                Description = input.Description,
                TransactionTime = input.TransactionTime
            };

            await InsertTransactionAsync(sentTransaction, true);

            // make sure income
            if (input.ToAmount < 0)
            {
                input.ToAmount *= -1;
            }

            var senderAccount = await this._accountRepository.FirstOrDefaultAsync(a => a.Id == input.AccountId);

            var receivedTransaction = new TransactionEditDto()
            {
                Amount = input.ToAmount,
                AccountId = input.ToAccountId,
                CategoryId = input.CategoryId,
                Description = $"Received from {senderAccount.Name}",
                TransactionTime = input.TransactionTime
            };

            await InsertTransactionAsync(receivedTransaction, true);
        }

        private static Dictionary<string, string> GetTransactionDataInDictionary(TransactionPreviewDto transactionPreviewDto)
        {
            return new Dictionary<string, string>
            {
                {"AccountName", transactionPreviewDto.Account.Name},
                {"CreatorUserName", transactionPreviewDto.CreatorUserName},
                {"CategoryName", transactionPreviewDto.Category.Name},
                {"CategoryIcon", transactionPreviewDto.Category.Icon},
                {"Amount", transactionPreviewDto.Amount.ToString(CultureInfo.InvariantCulture)},
                {"TransactionTime", transactionPreviewDto.TransactionTime.ToString("s", CultureInfo.InvariantCulture)},
                {"Description", transactionPreviewDto.Description},
                {"TransactionId",transactionPreviewDto.Id.ToString() }
            };
        }

        private async Task CreateTransactionCommentAsync(TransactionCommentEditDto input)
        {
            var transactionComment = ObjectMapper.Map<TransactionComment>(input);
            await _transactionCommentRepository.InsertAndGetIdAsync(transactionComment);
            await SendTransactionCommentPushNotificationAsync(input);
        }

        private async Task InsertTransactionAsync(TransactionEditDto input, bool isTransfer = false)
        {
            var transaction = ObjectMapper.Map<Transaction>(input);
            transaction.Balance = 0;
            transaction.IsTransferred = isTransfer;

            var transactionId = await _transactionRepository.InsertAndGetIdAsync(transaction);
            await CurrentUnitOfWork.SaveChangesAsync();
            await UpdateTransactionsBalanceInAccountAsync(input.AccountId);

            await SendNotificationAsync(transactionId, NotificationTypes.NewTransaction).ConfigureAwait(false);
        }

        private async Task SendTransactionCommentPushNotificationAsync(TransactionCommentEditDto input)
        {
            var currentUser = await _sessionAppService.GetCurrentLoginInformations();

            var transaction = await _transactionRepository.GetAll()
                .Include(t => t.Account)
                    .ThenInclude(account => account.Currency)
                .Include(t => t.Category)
                .Include(t => t.CreatorUser)
                .Where(t => t.Id == input.TransactionId)
                .FirstOrDefaultAsync();

            var transactionPreviewDto = ObjectMapper.Map<TransactionPreviewDto>(transaction);

            await _backgroundJobManager.EnqueueAsync<SendPushNotificationJob, SendPushNotificationJobArgs>(
                new SendPushNotificationJobArgs
                {
                    Contents = input.Content,
                    Headings = input.Id.HasValue
                        ? $"{currentUser.User.UserName.ToPascalCase()} updated a comment on a transaction done by {transactionPreviewDto.CreatorUserName}"
                        : $"New comment added by {currentUser.User.UserName.ToPascalCase()} on a transaction done by {transactionPreviewDto.CreatorUserName}.",
                    Data = GetTransactionDataInDictionary(transactionPreviewDto),
                    TenancyName = currentUser.Tenant.TenancyName.Trim().ToLowerInvariant()
                });
        }

        private async Task UpdateTransactionAsync(TransactionEditDto input)
        {
            var tenantId = AbpSession.TenantId;
            var transaction = await _transactionRepository.FirstOrDefaultAsync(t => t.Id == input.Id && t.Account.TenantId == tenantId);
            ObjectMapper.Map(input, transaction);

            await CurrentUnitOfWork.SaveChangesAsync();
            await UpdateTransactionsBalanceInAccountAsync(input.AccountId);
            await SendNotificationAsync(transaction.Id, NotificationTypes.UpdateTransaction).ConfigureAwait(false);
        }

        private async Task UpdateTransactionCommentAsync(TransactionCommentEditDto input)
        {
            var transactionComment = await _transactionCommentRepository.FirstOrDefaultAsync(c => c.Id == input.Id.Value);

            input.MapTo(transactionComment);

            await SendTransactionCommentPushNotificationAsync(input);
        }

        private async Task UpdateTransactionsBalanceInAccountAsync(Guid accountId)
        {
            var transactions = await
                    this._transactionRepository.GetAll()
                        .Where(t => t.AccountId == accountId)
                        .OrderBy(t => t.TransactionTime)
                        .ThenBy(t => t.CreationTime)
                        .ToListAsync();

            decimal currentBalance = 0;

            foreach (var transaction in transactions)
            {
                currentBalance += transaction.Amount;

                if (transaction.Balance == currentBalance)
                {
                    continue;
                }

                transaction.Balance = currentBalance;
                await this.CurrentUnitOfWork.SaveChangesAsync();
            }
        }
    }
}