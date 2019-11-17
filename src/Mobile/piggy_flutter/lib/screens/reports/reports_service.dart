import 'dart:async';
import 'package:piggy_flutter/services/app_service_base.dart';
import 'package:piggy_flutter/screens/reports/categorywise_recent_months_report_screen.dart';

class ReportsService extends AppServiceBase {
  Future<List<CategoryWiseRecentMonthsReportItem>>
      getCategoryWiseTransactionSummaryHistory() async {
    List<CategoryWiseRecentMonthsReportItem> data = [];
    var result = await rest.getAsync(
        'services/app/Report/GetCategoryWiseTransactionSummaryHistory?numberOfIteration=3&periodOfIteration=month&typeOfTransaction=expense');

    if (result.success) {
      // print('##### ${result.mappedResult}');
      result.result['items'].forEach((item) =>
          data.add(CategoryWiseRecentMonthsReportItem.fromJson(item)));
    }
    // print(data);
    return data;
  }
}
