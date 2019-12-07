import 'dart:async';

import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/screens/reports/categorywise_recent_months_report_screen.dart';
import 'package:piggy_flutter/screens/reports/reports_service.dart';
import 'package:rxdart/rxdart.dart';

// TODO: replace with bloc package
class ReportsBloc implements BlocBase {
  final ReportsService _reportService = ReportsService();

  final _categoryWiseTransactionSummaryHistorySubject =
      BehaviorSubject<List<CategoryWiseRecentMonthsReportItem>>();
  Stream<List<CategoryWiseRecentMonthsReportItem>>
      get categoryWiseTransactionSummaryHistory =>
          _categoryWiseTransactionSummaryHistorySubject.stream;

  ReportsBloc() {
    _reportService.getCategoryWiseTransactionSummaryHistory().then((result) {
      _categoryWiseTransactionSummaryHistorySubject.add(result);
    });
  }

  void dispose() {
    _categoryWiseTransactionSummaryHistorySubject?.close();
  }
}
