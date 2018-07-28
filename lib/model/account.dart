class Account {
  final String id, name, accountType, currencySymbol;
  final double currentBalance;

  Account(this.id, this.name, this.accountType, this.currencySymbol,
      this.currentBalance);

  Account.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        accountType = json['accountType'],
        currencySymbol = json['currency']['symbol'],
        currentBalance = json['currentBalance'];
}
