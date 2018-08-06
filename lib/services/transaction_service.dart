import 'dart:async';

import 'package:piggy_flutter/bloc/account_bloc.dart';
import 'package:piggy_flutter/model/transaction.dart';
import 'package:piggy_flutter/model/transaction_comment.dart';
import 'package:piggy_flutter/model/transaction_edit_dto.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';
import 'package:piggy_flutter/model/transaction_summary.dart';
import 'package:piggy_flutter/services/app_service_base.dart';
import 'package:intl/intl.dart';

class GetTransactionsInput {
  String type;
  String accountId;
  String startDate;
  String endDate;
  String query;
  String view;

  GetTransactionsInput(this.type, this.accountId, this.startDate, this.endDate,
      this.view); // where the data is showing
}

class TransferInput {
  final String id, description, accountId, toAccountId, transactionTime;
  final double amount, toAmount;
  final int categoryId;
  final AccountBloc accountBloc;

  TransferInput(
      this.id,
      this.description,
      this.accountId,
      this.transactionTime,
      this.amount,
      this.categoryId,
      this.accountBloc,
      this.toAmount,
      this.toAccountId);
}

class TransactionService extends AppServiceBase {
  Future<List<TransactionGroupItem>> getTransactions(
      GetTransactionsInput input) async {
    List<Transaction> transactions = [];
    var result = await rest
        .postAsync<dynamic>('services/app/transaction/GetTransactionsAsync', {
      "type": input.type,
      "accountId": input.accountId,
      "startDate": input.startDate,
      "endDate": input.endDate
    });

    if (result.mappedResult != null) {
      result.mappedResult['items'].forEach((transaction) {
        transactions.add(Transaction.fromJson(transaction));
      });
    }
    var groupedTransactions = groupTransactions(transactions);
    return groupedTransactions;
  }

  Future<TransactionSummary> getTransactionSummary(String duration) async {
    var result = await rest.postAsync<dynamic>(
        'services/app/tenantDashboard/GetTransactionSummary', {
      "duration": duration,
    });

    if (result.mappedResult != null) {
      return TransactionSummary.fromJson(result.mappedResult);
    }

    return null;
  }

  Future<TransactionEditDto> getTransactionForEdit(String id) async {
    var result = await rest
        .postAsync<dynamic>('services/app/transaction/GetTransactionForEdit', {
      "id": id,
    });

    if (result.mappedResult != null) {
      return TransactionEditDto.fromJson(result.mappedResult);
    }

    return null;
  }

  Future<List<TransactionComment>> getTransactionComments(String id) async {
    var comments = List<TransactionComment>();
    var result = await rest
        .postAsync<dynamic>('services/app/transaction/GetTransactionComments', {
      "id": id,
    });
    print(result.mappedResult);
    if (result.mappedResult != null) {
      result.mappedResult['items'].forEach((comment) {
        comments.add(TransactionComment.fromJson(comment));
      });
    }

    return comments;
  }

  Future<Null> createOrUpdateTransaction(TransactionEditDto input) async {
    await rest.postAsync('services/app/transaction/CreateOrUpdateTransaction', {
      "id": input.id,
      "description": input.description,
      "amount": input.amount,
      "categoryId": input.categoryId,
      "accountId": input.accountId,
      "transactionTime": input.transactionTime
    });
  }

  Future<Null> saveTransactionComment(
      String transactionId, String content) async {
    await rest.postAsync(
        'services/app/transaction/CreateOrUpdateTransactionCommentAsync', {
      "transactionId": transactionId,
      "content": content,
    });
  }

  Future<Null> transfer(TransferInput input) async {
    await rest.postAsync('services/app/transaction/TransferAsync', {
      "id": input.id,
      "description": input.description,
      "amount": input.amount,
      "toAmount": input.toAmount,
      "categoryId": input.categoryId,
      "accountId": input.accountId,
      "toAccountId": input.toAccountId,
      "transactionTime": input.transactionTime
    });
  }

  List<TransactionGroupItem> groupTransactions(List<Transaction> items,
      [String groupBy = 'transactionTime']) {
    List<TransactionGroupItem> groupedItems = [];

    if (groupBy == 'transactionTime') {
      for (var i = 0; i < items.length; i++) {
        var date = DateTime.parse(items[i].transactionTime);
        var index = date.year * 10000 + (date.month * 100) + date.day;
        var day = groupedItems.firstWhere((o) => o.index == index,
            orElse: () => null);

        if (day == null) {
          var formatter = new DateFormat("EEE, MMM d, ''yy");
          day = new TransactionGroupItem(index, formatter.format(date));

          groupedItems.add(day);
        }

//         if (items[i]['amountInDefaultCurrency'] > 0) {
//           day['totalInflow'] += items[i]['amountInDefaultCurrency'];
//         } else {
//           day['totalOutflow'] += items[i]['amountInDefaultCurrency'];
//         }
        day.transactions.add(items[i]);
      }
    }

    return groupedItems;
  }
}
