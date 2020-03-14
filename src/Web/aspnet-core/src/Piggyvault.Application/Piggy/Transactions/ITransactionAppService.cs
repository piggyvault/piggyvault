using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Piggyvault.Piggy.Transactions.Dto;
using System;
using System.Threading.Tasks;
using Piggyvault.Piggy.Notifications;

namespace Piggyvault.Piggy.Transactions
{
    public interface ITransactionAppService : IApplicationService
    {
        /// <summary>
        /// create a copy of transaction
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        Task CopyTransactionAsync(EntityDto<Guid> input);

        Task CreateOrUpdateTransaction(TransactionEditDto input);

        Task CreateOrUpdateTransactionCommentAsync(TransactionCommentEditDto input);

        Task DeleteTransaction(EntityDto<Guid> input);

        Task<GetTransactionSummaryOutput> GetSummary(GetTransactionSummaryInput input);

        Task<ListResultDto<TransactionCommentPreviewDto>> GetTransactionComments(EntityDto<Guid> input);

        Task<TransactionEditDto> GetTransactionForEdit(EntityDto<Guid> input);

        /// <summary>
        /// The get transactions async.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        Task<PagedResultDto<TransactionPreviewDto>> GetTransactionsAsync(GetTransactionsInput input);

        /// <summary>
        /// The get type ahead suggestions async.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        Task<ListResultDto<string>> GetTypeAheadSuggestionsAsync(GetTypeAheadSuggestionsInput input);

        /// <summary>
        /// The re calculate all accounts transaction balance of user.
        /// </summary>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        Task ReCalculateAllAccountsTransactionBalanceOfUserAsync();

        Task SendNotificationAsync(Guid transactionId, NotificationTypes notificationType);

        /// <summary>
        /// The transfer async.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        Task TransferAsync(TransferEditDto input);
    }
}