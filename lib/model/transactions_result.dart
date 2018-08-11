import 'package:piggy_flutter/model/transaction_group_item.dart';

class TransactionsResult {
  final List<TransactionGroupItem> items;

  TransactionsResult(this.items);

  bool get isPopulated => items.isNotEmpty;

  bool get isEmpty => items.isEmpty;
}
