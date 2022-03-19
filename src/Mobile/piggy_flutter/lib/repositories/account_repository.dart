import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/piggy_api_client.dart';

class AccountRepository {
  AccountRepository({required this.piggyApiClient})
      : assert(piggyApiClient != null);

  final PiggyApiClient piggyApiClient;

  Future<TenantAccountsResult> getTenantAccounts() async {
    return await piggyApiClient.getTenantAccounts();
  }

  Future<Account> getAccountDetails(String accountId) async {
    return await piggyApiClient.getAccountDetails(accountId);
  }

  Future<ApiResponse<dynamic>> createOrUpdateAccount(
      AccountFormModel input) async {
    return await piggyApiClient.createOrUpdateAccount(input);
  }

  Future<List<Currency>> getCurrencies() async {
    return await piggyApiClient.getCurrencies();
  }

  Future<List<AccountType>> getAccountTypes() async {
    return await piggyApiClient.getAccountTypes();
  }

  Future<AccountFormModel?> getAccountForEdit(String? id) async {
    return await piggyApiClient.getAccountForEdit(id);
  }
}
