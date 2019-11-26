import 'package:piggy_flutter/models/models.dart';

class GetTransactionsInput {
  String type;
  String accountId;
  DateTime startDate;
  DateTime endDate;
  String query;
  TransactionsGroupBy groupBy;

  GetTransactionsInput(
      {this.type,
      this.accountId,
      this.startDate,
      this.endDate,
      this.groupBy}); // where the data is showing
}
