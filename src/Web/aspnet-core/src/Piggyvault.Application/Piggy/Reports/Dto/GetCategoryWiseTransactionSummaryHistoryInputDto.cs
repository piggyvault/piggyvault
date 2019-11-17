namespace Piggyvault.Piggy.Reports.Dto
{
    public class GetCategoryWiseTransactionSummaryHistoryInputDto
    {
        public int NumberOfIteration { get; set; }

        public string PeriodOfIteration { get; set; }

        public string TypeOfTransaction { get; set; }
    }
}