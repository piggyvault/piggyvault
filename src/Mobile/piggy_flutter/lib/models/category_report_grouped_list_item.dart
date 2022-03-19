import 'models.dart';

class CategoryReportGroupedListItem {
  CategoryReportGroupedListItem({this.categoryIcon, this.categoryName}) {}

  List<CategoryReportGroupedListItemAccount> accounts = [];

  final String? categoryIcon, categoryName;
  double totalAmountInDefaultCurrency = 0;
}
