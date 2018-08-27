import 'dart:async';
import 'package:piggy_flutter/services/app_service_base.dart';
import 'package:piggy_flutter/ui/screens/reports/categorywise_recent_months_report_screen.dart';

class ReportsService extends AppServiceBase {
  Future<List<CategoryWiseRecentMonthsReportItem>>
      getCategoryWiseTransactionSummaryHistory() async {
    List<CategoryWiseRecentMonthsReportItem> data = [];
    var result = await rest.postAsync(
        'services/app/tenantDashboard/GetCategoryWiseTransactionSummaryHistory',
        {
          "numberOfIteration": 3,
          "periodOfIteration": 'month',
          "typeOfTransaction": 'expense'
        });

    if (result.mappedResult != null) {
      // print('##### ${result.mappedResult}');
      result.mappedResult['items'].forEach((item) =>
          data.add(CategoryWiseRecentMonthsReportItem.fromJson(item)));
    }
    // print(data);
    return data;
  }
}
