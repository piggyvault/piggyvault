class Transaction {
  final String categoryName,
      description,
      creatorUserName,
      accountName,
      transactionTime,
      accountCurrencySymbol;
  final double amount;

  Transaction(
      this.categoryName,
      this.description,
      this.creatorUserName,
      this.accountName,
      this.accountCurrencySymbol,
      this.amount,
      this.transactionTime);

  Transaction.fromJson(Map<String, dynamic> json)
      : categoryName = json['category']['name'],
        description = json['description'],
        creatorUserName = json['creatorUserName'],
        accountName = json['account']['name'],
        accountCurrencySymbol = json['account']['currency']['symbol'],
        transactionTime = json['transactionTime'],
        amount = json['amount'];
}
