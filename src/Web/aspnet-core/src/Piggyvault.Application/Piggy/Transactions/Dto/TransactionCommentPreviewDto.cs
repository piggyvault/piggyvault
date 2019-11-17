using Abp.AutoMapper;
using System;

namespace Piggyvault.Piggy.Transactions.Dto
{
    [AutoMapFrom(typeof(TransactionComment))]
    public class TransactionCommentPreviewDto
    {
        #region Public Properties

        public string Content { get; set; }
        public DateTime CreationTime { get; set; }
        public long CreatorUserId { get; set; }
        public string CreatorUserName { get; set; }
        public Guid Id { get; set; }

        #endregion Public Properties
    }
}