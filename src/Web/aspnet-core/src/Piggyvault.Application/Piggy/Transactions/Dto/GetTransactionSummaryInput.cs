using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.Transactions.Dto
{
    public class GetTransactionSummaryInput
    {
        public Guid? AccountId { get; set; }
        public string Duration { get; set; }
        public DateTime? EndDate { get; set; }
        public DateTime? StartDate { get; set; }
    }
}