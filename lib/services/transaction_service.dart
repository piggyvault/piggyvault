import 'dart:async';

import 'package:piggy_flutter/bloc/account_bloc.dart';
import 'package:piggy_flutter/model/transaction.dart';
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

class SaveTransactionInput {
  final String id, description, accountId, transactionTime;
  final double amount;
  final int categoryId;
  final AccountBloc accountBloc;

  SaveTransactionInput(this.id, this.description, this.accountId,
      this.transactionTime, this.amount, this.categoryId, this.accountBloc);
}

class TransactionService extends AppServiceBase {
  List<TransactionGroupItem> recentTransactions;
  TransactionSummary transactionSummary;

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

    print('getTransactions========= result is ${result.mappedResult}');

    if (result.mappedResult != null) {
      result.mappedResult['items'].forEach((transaction) {
        transactions.add(Transaction.fromJson(transaction));
      });
    }

    var groupedTransactions = groupTransactions(transactions);

    if (input.view == 'recent') {
      this.recentTransactions = groupedTransactions;
    }

    return groupedTransactions;
  }

  Future<Null> getTransactionSummary(String duration) async {
    var result = await rest.postAsync<dynamic>(
        'services/app/tenantDashboard/GetTransactionSummary', {
      "duration": duration,
    });

//    print('getTransactionSummary result is ${result.mappedResult}');

    if (result.mappedResult != null) {
      this.transactionSummary =
          TransactionSummary.fromJson(result.mappedResult);
    }
  }

  Future<Null> createOrUpdateTransaction(SaveTransactionInput input) async {
    var restult = await rest
        .postAsync('services/app/transaction/CreateOrUpdateTransaction', {
      "id": input.id,
      "description": input.description,
      "amount": input.amount,
      "categoryId": input.categoryId,
      "accountId": input.accountId,
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
