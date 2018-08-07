import 'package:piggy_flutter/model/transaction.dart';

class TransactionGroupItem {
  final String title;
  List<Transaction> transactions = [];
  double totalInflow = 0.0, totalOutflow = 0.0;

  TransactionGroupItem({this.title});
}

enum TransactionsGroupBy { Date, Category }
