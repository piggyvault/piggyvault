using Abp.AutoMapper;
using Piggyvault.Piggy.Accounts.Dto;
using Piggyvault.Piggy.Categories.Dto;
using System;

namespace Piggyvault.Piggy.Transactions.Dto
{
    /// <summary>
    /// The transaction preview dto.
    /// </summary>
    [AutoMapFrom(typeof(Transaction))]
    public class TransactionPreviewDto
    {
        public AccountPreviewDto Account { get; set; }
        public decimal Amount { get; set; }
        public decimal AmountInDefaultCurrency { get; set; }
        public decimal Balance { get; set; }
        public CategoryEditDto Category { get; set; }
        public string CreatorUserName { get; set; }
        public string Description { get; set; }
        public Guid Id { get; set; }
        public DateTime TransactionTime { get; set; }
    }
}