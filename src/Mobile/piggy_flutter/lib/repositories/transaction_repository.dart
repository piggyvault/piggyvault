import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/api_response.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/piggy_api_client.dart';

class TransactionRepository {
  final PiggyApiClient piggyApiClient;

  TransactionRepository({@required this.piggyApiClient})
      : assert(piggyApiClient != null);

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
    return await piggyApiClient.getTransactions(input);
  }
}
