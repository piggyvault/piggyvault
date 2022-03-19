class CategoryReportListDto {
  CategoryReportListDto({
    this.accountName,
    this.amountInDefaultCurrency,
    this.amount,
    this.categoryIcon,
    this.categoryName,
    this.currencyCode,
  });

  CategoryReportListDto.fromJson(Map<String, dynamic> json)
      : accountName = json['accountName'],
        amount = json['amount'],
        amountInDefaultCurrency = json['amountInDefaultCurrency'],
        categoryIcon = json['categoryIcon'],
        categoryName = json['categoryName'],
        currencyCode = json['currencyCode'];

  final String? accountName, categoryIcon, categoryName, currencyCode;
  final double? amount, amountInDefaultCurrency;
}
