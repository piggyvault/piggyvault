namespace Piggyvault.Piggy.Transactions.Dto
{
    public class GetTransactionSummaryOutput
    {
        public virtual decimal AccountExpense { get; set; }
        public virtual decimal AccountIncome { get; set; }
        public virtual decimal AccountSaved { get; set; }
        public virtual string CurrencySymbol { get; set; }
        public virtual string ExpensePercentage { get; set; }
        public virtual string IncomePercentage { get; set; }
        public virtual string NetWorthPercentage { get; set; }
        public virtual string SavedPercentage { get; set; }
        public virtual decimal TenantExpense { get; set; }
        public virtual decimal TenantIncome { get; set; }
        public virtual decimal TenantNetWorth { get; set; }

        public virtual decimal TenantSaved { get; set; }
        public int TotalFamilyTransactionsCount { get; set; }
        public virtual decimal UserExprense { get; set; }
        public virtual decimal UserIncome { get; set; }
        public virtual decimal UserNetWorth { get; set; }
        public virtual decimal UserSaved { get; set; }
    }
}