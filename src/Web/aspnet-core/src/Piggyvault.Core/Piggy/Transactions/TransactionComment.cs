using Abp.Domain.Entities.Auditing;
using Piggyvault.Authorization.Users;
using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace Piggyvault.Piggy.Transactions
{
    [Table("PvTransactionComment")]
    public class TransactionComment : FullAuditedEntity<Guid, User>
    {
        public string Content { get; set; }

        [ForeignKey("TransactionId")]
        public virtual Transaction Transaction { get; set; }

        public Guid TransactionId { get; set; }
    }
}