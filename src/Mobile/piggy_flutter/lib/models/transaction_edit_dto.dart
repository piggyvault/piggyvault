class TransactionEditDto {
  String? id, description, accountId, transactionTime;
  double? amount;
  String? categoryId;

  TransactionEditDto(
      {this.id,
      this.description,
      this.accountId,
      this.transactionTime,
      this.amount,
      this.categoryId});

  TransactionEditDto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        description = json['description'],
        amount = json['amount'],
        categoryId = json['categoryId'],
        transactionTime = json['transactionTime'],
        accountId = json['accountId'];
}
