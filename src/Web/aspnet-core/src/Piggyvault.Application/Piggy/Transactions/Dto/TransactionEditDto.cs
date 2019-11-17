using System.ComponentModel.DataAnnotations;
using Abp.AutoMapper;
using System;

namespace Piggyvault.Piggy.Transactions.Dto
{
    [AutoMap(typeof(Transaction))]
    public class TransactionEditDto
    {
        public virtual Guid AccountId { get; set; }
        public virtual decimal Amount { get; set; }
        public virtual Guid CategoryId { get; set; }

        [MaxLength(Transaction.MaxDescriptionLength)]
        public virtual string Description { get; set; }

        public virtual Guid? Id { get; set; }

        [Required]
        public virtual DateTime TransactionTime { get; set; }
    }
}