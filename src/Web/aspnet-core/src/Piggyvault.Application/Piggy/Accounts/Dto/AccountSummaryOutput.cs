using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.Accounts.Dto
{
    public class AccountSummaryOutput
    {
        public virtual decimal TenantExpense { get; set; }
        public virtual decimal TenantSaved { get; set; }
        public virtual decimal UserExprense { get; set; }
        public virtual decimal UserIncome { get; set; }
        public virtual decimal UserSaved { get; set; }
    }
}