using Piggyvault.Piggy.Transactions.Dto;
using System.Collections.Generic;

namespace Piggyvault.Piggy.Reports.Dto
{
    public class TransactionSummaryInGetCategoryWiseTransactionSummaryHistoryOuputDto
    {
        public decimal Total { get; set; }

        public virtual List<TransactionPreviewDto> Transactions { get; set; }
    }
}