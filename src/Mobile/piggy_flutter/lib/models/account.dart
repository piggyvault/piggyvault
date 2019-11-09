class Account {
  final String id, name, accountType, currencySymbol, currencyCode;
  final double currentBalance;

  Account(this.id, this.name, this.accountType, this.currencySymbol,
      this.currentBalance, this.currencyCode);

  Account.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        accountType = json['accountType'],
        currencySymbol = json['currency']['symbol'],
        currencyCode = json['currency']['code'],
        currentBalance = json['currentBalance'];

  @override
  String toString() {
    return '$name - ${currentBalance.toString()}';
  }
}
