class TransferInput {
  final String? id, description, accountId, toAccountId, transactionTime;
  final double amount, toAmount;
  final String? categoryId;

  TransferInput(this.id, this.description, this.accountId, this.transactionTime,
      this.amount, this.categoryId, this.toAmount, this.toAccountId);
}
