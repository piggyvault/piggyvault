using System.Collections.Generic;

namespace Piggyvault.Piggy.Reports.Dto
{
    public class GetCategoryWiseTransactionSummaryHistoryOuputDto
    {
        public GetCategoryWiseTransactionSummaryHistoryOuputDto()
        {
            Datasets = new List<TransactionSummaryInGetCategoryWiseTransactionSummaryHistoryOuputDto>();
        }

        public string CategoryName { get; set; }

        public List<TransactionSummaryInGetCategoryWiseTransactionSummaryHistoryOuputDto> Datasets { get; set; }
    }
}