class Transaction {
  Transaction(
      {this.id,
      this.balance,
      this.categoryName,
      this.categoryIcon,
      this.description,
      this.creatorUserName,
      this.accountName,
      this.accountCurrencySymbol,
      this.amount,
      this.transactionTime,
      this.amountInDefaultCurrency});

  Transaction.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        balance = json['balance'],
        categoryName = json['category']['name'],
        categoryIcon = json['category']['icon'],
        description = json['description'],
        creatorUserName = json['creatorUserName'],
        accountName = json['account']['name'],
        accountCurrencySymbol = json['account']['currency']['symbol'],
        transactionTime = json['transactionTime'],
        amount = json['amount'],
        amountInDefaultCurrency = json['amountInDefaultCurrency'];

  final String? id,
      categoryName,
      categoryIcon,
      description,
      creatorUserName,
      accountName,
      transactionTime,
      accountCurrencySymbol;
  final double? amount, amountInDefaultCurrency, balance;
}
