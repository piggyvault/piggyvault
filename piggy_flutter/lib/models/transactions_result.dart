import 'package:flutter/material.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/models/transaction_group_item.dart';

class TransactionsResult {
  final List<TransactionGroupItem> sections;
  final List<Transaction> transactions;
  TransactionsResult({@required this.sections, @required this.transactions});

  bool get isPopulated => sections.isNotEmpty;

  bool get isEmpty => sections.isEmpty;
}
