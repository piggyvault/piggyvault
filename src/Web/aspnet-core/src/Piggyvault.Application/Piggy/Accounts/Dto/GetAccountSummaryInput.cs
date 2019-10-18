using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.Accounts.Dto
{
    public class GetAccountSummaryInput
    {
        public string Duration { get; set; }
        public DateTime? EndDate { get; set; }
        public DateTime? StartDate { get; set; }
    }
}