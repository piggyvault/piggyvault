import 'package:collection/collection.dart' show IterableExtension;
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/piggy_api_client.dart';

class ReportRepository {
  ReportRepository({required this.piggyApiClient})
      : assert(piggyApiClient != null);

  final PiggyApiClient piggyApiClient;

  Future<List<CategoryWiseRecentMonthsReportItem>>
      getCategoryWiseTransactionSummaryHistory() async {
    return await piggyApiClient.getCategoryWiseTransactionSummaryHistory();
  }

  Future<List<CategoryReportGroupedListItem>> getCategoryReport(
      GetCategoryReportInput input) async {
    final List<CategoryReportListDto> items =
        await piggyApiClient.getCategoryReport(input);

    List<CategoryReportGroupedListItem> output = [];

    for (CategoryReportListDto item in items) {
      CategoryReportGroupedListItem? categoryGroup = output.firstWhereOrNull(
          (CategoryReportGroupedListItem i) =>
              i.categoryName == item.categoryName);

      if (categoryGroup == null) {
        categoryGroup = CategoryReportGroupedListItem(
            categoryIcon: item.categoryIcon, categoryName: item.categoryName);

        output.add(categoryGroup);
      }

      categoryGroup.accounts.add(CategoryReportGroupedListItemAccount(
          accountName: item.accountName,
          amount: item.amount,
          amountInDefaultCurrency: item.amountInDefaultCurrency,
          currencyCode: item.currencyCode));

      categoryGroup.totalAmountInDefaultCurrency +=
          item.amountInDefaultCurrency!;
    }

    return output;
  }
}
