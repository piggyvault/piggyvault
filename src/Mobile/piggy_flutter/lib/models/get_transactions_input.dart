import 'package:piggy_flutter/models/models.dart';

class GetTransactionsInput {
  GetTransactionsInput(
      {this.type,
      this.accountId,
      this.categoryId,
      this.startDate,
      this.endDate,
      this.groupBy}); // where the data is showing

  String? type;
  String? accountId;
  String? categoryId;
  DateTime? startDate;
  DateTime? endDate;
  String? query;
  TransactionsGroupBy? groupBy;
}
