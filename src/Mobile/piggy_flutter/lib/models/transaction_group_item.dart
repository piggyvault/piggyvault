import 'package:flutter/material.dart';
import 'package:piggy_flutter/models/transaction.dart';

class TransactionGroupItem {
  final String title;
  final TransactionsGroupBy groupby;
  List<Transaction> transactions = [];
  double totalInflow = 0.0, totalOutflow = 0.0;

  TransactionGroupItem({@required this.title, @required this.groupby});
}

enum TransactionsGroupBy { Date, Category }
