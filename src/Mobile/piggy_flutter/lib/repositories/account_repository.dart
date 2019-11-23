import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/piggy_api_client.dart';

class AccountRepository {
  final PiggyApiClient piggyApiClient;

  AccountRepository({@required this.piggyApiClient})
      : assert(piggyApiClient != null);

  Future<TenantAccountsResult> getTenantAccounts() async {
    return await piggyApiClient.getTenantAccounts();
  }
}
