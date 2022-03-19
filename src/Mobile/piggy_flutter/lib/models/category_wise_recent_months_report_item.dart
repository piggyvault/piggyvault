import 'models.dart';

class CategoryWiseRecentMonthsReportItem {
  CategoryWiseRecentMonthsReportItem(this.categoryName, this.datasets);

  CategoryWiseRecentMonthsReportItem.fromJson(Map<String, dynamic> json)
      : categoryName = json['categoryName'],
        datasets =
            (json['datasets'] as List).map((i) => Dataset.fromJson(i)).toList();
  final String? categoryName;
  final List<Dataset> datasets;
}
