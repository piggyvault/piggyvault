import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/piggy_api_client.dart';

class ReportRepository {
  ReportRepository({@required this.piggyApiClient})
      : assert(piggyApiClient != null);

  final PiggyApiClient piggyApiClient;

  Future<List<CategoryWiseRecentMonthsReportItem>>
      getCategoryWiseTransactionSummaryHistory() async {
    return await piggyApiClient.getCategoryWiseTransactionSummaryHistory();
  }
}
