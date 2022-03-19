import 'package:flutter/material.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/models/transaction_group_item.dart';
import 'package:piggy_flutter/utils/common.dart';

class TransactionsResult {
  TransactionsResult({required this.sections, required this.transactions}) {
    transactions.forEach((t) {
      if (t.amount! > 0) {
        _totalIncome += t.amountInDefaultCurrency!;
      } else {
        _totalExpense += t.amountInDefaultCurrency!;
      }
    });
  }

  final List<TransactionGroupItem> sections;
  final List<Transaction> transactions;

  double _totalExpense = 0;
  double _totalIncome = 0;

  bool get isPopulated => sections.isNotEmpty;

  bool get isEmpty => sections.isEmpty;

  String get totalExpense => _totalExpense.toMoney();
  String get totalIncome => _totalIncome.toMoney();
}
