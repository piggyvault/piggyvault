class Transaction {
  final String id,
      categoryName,
      description,
      creatorUserName,
      accountName,
      transactionTime,
      accountCurrencySymbol;
  final double amount, amountInDefaultCurrency;

  Transaction(
      {this.id,
      this.categoryName,
      this.description,
      this.creatorUserName,
      this.accountName,
      this.accountCurrencySymbol,
      this.amount,
      this.transactionTime,
      this.amountInDefaultCurrency});

  Transaction.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        categoryName = json['category']['name'],
        description = json['description'],
        creatorUserName = json['creatorUserName'],
        accountName = json['account']['name'],
        accountCurrencySymbol = json['account']['currency']['symbol'],
        transactionTime = json['transactionTime'],
        amount = json['amount'],
        amountInDefaultCurrency = json['amountInDefaultCurrency'];
}
