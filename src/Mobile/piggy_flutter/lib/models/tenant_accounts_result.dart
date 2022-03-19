import 'package:piggy_flutter/models/account.dart';

class TenantAccountsResult {
  final List<Account>? userAccounts;
  final List<Account>? familyAccounts;

  TenantAccountsResult({this.userAccounts, this.familyAccounts});
}
