class TransactionSummary {
  double tenantNetWorth = 0.0,
      userNetWorth = 0.0,
      tenantIncome = 0.0,
      userIncome = 0.0,
      userExpense = 0.0,
      tenantExpense = 0.0,
      tenantSaved = 0.0,
      userSaved = 0.0;

  TransactionSummary(
      this.tenantNetWorth,
      this.userNetWorth,
      this.tenantIncome,
      this.userIncome,
      this.userExpense,
      this.tenantExpense,
      this.tenantSaved,
      this.userSaved);

  TransactionSummary.fromJson(Map<String, dynamic> json)
      : tenantNetWorth = json['tenantNetWorth'],
        userNetWorth = json['userNetWorth'],
        tenantIncome = json['tenantIncome'],
        userIncome = json['userIncome'],
        tenantExpense = json['tenantExpense'],
        userExpense = json['userExprense'],
        tenantSaved = json['tenantSaved'],
        userSaved = json['userSaved'];
}
