import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/models/api_response.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/piggy_api_client.dart';

class TransactionRepository {
  TransactionRepository({required this.piggyApiClient})
      : assert(piggyApiClient != null);

  final PiggyApiClient piggyApiClient;

  Future<TransactionSummary> getTransactionSummary(String duration) async {
    return await piggyApiClient.getTransactionSummary(duration);
  }

  Future<ApiResponse<dynamic>> createOrUpdateTransaction(
      TransactionEditDto input) async {
    return await piggyApiClient.createOrUpdateTransaction(input);
  }

  Future<ApiResponse<dynamic>> transfer(TransferInput input) async {
    return await piggyApiClient.transfer(input);
  }

  Future<TransactionsResult> getTransactions(GetTransactionsInput input) async {
    final List<Transaction> transactions =
        await piggyApiClient.getTransactions(input);

    return TransactionsResult(
        sections: groupTransactions(
            transactions: transactions, groupBy: input.groupBy),
        transactions: transactions);
  }

  Future<void> deleteTransaction(String id) async {
    await piggyApiClient.deleteTransaction(id);
  }

  Future<void> createOrUpdateTransactionComment(
      String transactionId, String content) async {
    await piggyApiClient.createOrUpdateTransactionComment(
        transactionId, content);
  }

  Future<List<TransactionComment>> getTransactionComments(String id) async {
    return await piggyApiClient.getTransactionComments(id);
  }

  // Utils

  List<TransactionGroupItem> groupTransactions(
      {required List<Transaction> transactions,
      TransactionsGroupBy? groupBy = TransactionsGroupBy.Date}) {
    List<TransactionGroupItem> sections = [];
    var formatter = DateFormat("EEE, MMM d, ''yy");
    String? key;

    transactions.forEach((Transaction transaction) {
      if (groupBy == TransactionsGroupBy.Date) {
        key = formatter.format(DateTime.parse(transaction.transactionTime!));
      } else if (groupBy == TransactionsGroupBy.Category) {
        key = transaction.categoryName;
      }

      TransactionGroupItem? section =
          sections.firstWhereOrNull((TransactionGroupItem o) => o.title == key);

      if (section == null) {
        section = TransactionGroupItem(title: key, groupby: groupBy);
        sections.add(section);
      }

      if (transaction.amountInDefaultCurrency! > 0) {
        section.totalInflow += transaction.amountInDefaultCurrency!;
      } else {
        section.totalOutflow += transaction.amountInDefaultCurrency!;
      }

      section.transactions.add(transaction);
    });

    return sections;
  }
}
