import 'dart:async';

import 'package:piggy_flutter/models/api_response.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/models/transaction_comment.dart';
import 'package:piggy_flutter/models/transaction_edit_dto.dart';
import 'package:piggy_flutter/models/transaction_group_item.dart';
import 'package:piggy_flutter/models/transaction_summary.dart';
import 'package:piggy_flutter/models/transactions_result.dart';
import 'package:piggy_flutter/services/app_service_base.dart';
import 'package:intl/intl.dart';

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

class TransactionService extends AppServiceBase {
  Future<TransactionsResult> getTransactions(GetTransactionsInput input) async {
    List<Transaction> transactions = [];

    var params = '';

    if (input.type != null) params += 'type=${input.type}';

    if (input.accountId != null) params += '&accountId=${input.accountId}';

    if (input.startDate != null && input.startDate.toString() != '')
      params += '&startDate=${input.startDate}';

    if (input.endDate != null && input.endDate.toString() != '')
      params += '&endDate=${input.endDate}';

    var result = await rest
        .getAsync<dynamic>('services/app/transaction/GetTransactions?$params');

    if (result.success) {
      result.result['items'].forEach((transaction) {
        transactions.add(Transaction.fromJson(transaction));
      });
    }
    return TransactionsResult(
        sections: groupTransactions(
            transactions: transactions, groupBy: input.groupBy),
        transactions: transactions);
  }

  Future<TransactionEditDto> getTransactionForEdit(String id) async {
    var result = await rest.getAsync<dynamic>(
        'services/app/transaction/GetTransactionForEdit?id=$id');

    if (result.success != null) {
      return TransactionEditDto.fromJson(result.result);
    }

    return null;
  }

  Future<List<TransactionComment>> getTransactionComments(String id) async {
    var comments = List<TransactionComment>();
    var result = await rest.getAsync<dynamic>(
        'services/app/transaction/GetTransactionComments?id=$id');
    if (result.success) {
      result.result['items'].forEach((comment) {
        comments.add(TransactionComment.fromJson(comment));
      });
    }

    return comments;
  }

  Future<ApiResponse<dynamic>> deleteTransaction(String id) async {
    final result =
        await rest.postAsync('services/app/transaction/DeleteTransaction', {
      "id": id,
    });

    return result;
  }

  Future<Null> saveTransactionComment(
      String transactionId, String content) async {
    await rest.postAsync(
        'services/app/transaction/CreateOrUpdateTransactionComment', {
      "transactionId": transactionId,
      "content": content,
    });
  }

  List<TransactionGroupItem> groupTransactions(
      {List<Transaction> transactions,
      TransactionsGroupBy groupBy = TransactionsGroupBy.Date}) {
    List<TransactionGroupItem> sections = [];
    var formatter = DateFormat("EEE, MMM d, ''yy");
    String key;

    transactions.forEach((transaction) {
      if (groupBy == TransactionsGroupBy.Date) {
        key = formatter.format(DateTime.parse(transaction.transactionTime));
      } else if (groupBy == TransactionsGroupBy.Category) {
        key = transaction.categoryName;
      }

      var section =
          sections.firstWhere((o) => o.title == key, orElse: () => null);

      if (section == null) {
        section = TransactionGroupItem(title: key, groupby: groupBy);
        sections.add(section);
      }

      if (transaction.amountInDefaultCurrency > 0) {
        section.totalInflow += transaction.amountInDefaultCurrency;
      } else {
        section.totalOutflow += transaction.amountInDefaultCurrency;
      }

      section.transactions.add(transaction);
    });

    return sections;
  }
}
