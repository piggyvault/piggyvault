import 'package:flutter/material.dart';
import 'package:piggy_flutter/models/transaction.dart';

class TransactionGroupItem {
  TransactionGroupItem({required this.title, required this.groupby});

  final String? title;
  final TransactionsGroupBy? groupby;
  List<Transaction> transactions = [];
  double totalInflow = 0.0, totalOutflow = 0.0;
}

enum TransactionsGroupBy { Date, Category }
