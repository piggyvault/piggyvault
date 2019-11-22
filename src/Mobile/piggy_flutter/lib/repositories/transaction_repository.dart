import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/piggy_api_client.dart';

class TransactionRepository {
  final PiggyApiClient piggyApiClient;

  TransactionRepository({@required this.piggyApiClient})
      : assert(piggyApiClient != null);

  Future<TransactionSummary> getTransactionSummary(String duration) async {
    return await piggyApiClient.getTransactionSummary(duration);
  }
}
