class CategoryReportGroupedListItemAccount {
  CategoryReportGroupedListItemAccount({
    this.accountName,
    this.amountInDefaultCurrency,
    this.amount,
    this.currencyCode,
  });

  final String? accountName, currencyCode;
  final double? amount, amountInDefaultCurrency;
}
