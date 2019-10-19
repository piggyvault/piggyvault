using Abp.AutoMapper;
using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.Transactions.Dto
{
    [AutoMap(typeof(TransactionComment))]
    public class TransactionCommentEditDto
    {
        public string Content { get; set; }
        public Guid? Id { get; set; }
        public Guid TransactionId { get; set; }
    }
}