using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.Transactions.Dto
{
    public class GetTenantTransactionsInput
    {
        public DateTime EndDate { get; set; }
        public DateTime StartDate { get; set; }
    }
}