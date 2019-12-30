import 'models.dart';

class CategoryReportGroupedListItem {
  CategoryReportGroupedListItem({this.categoryIcon, this.categoryName}) {
    totalAmountInDefaultCurrency = 0;
  }

  List<CategoryReportGroupedListItemAccount> accounts = [];

  final String categoryIcon, categoryName;
  double totalAmountInDefaultCurrency;
}
