import 'dart:async';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/services/app_service_base.dart';

class AccountService extends AppServiceBase {
  List<Account> userAccounts;
  List<Account> familyAccounts;

  Future<Null> getTenantAccounts() async {
    List<Account> userAccountItems = [];
    List<Account> familyAccountItems = [];
    var result = await rest.postAsync<dynamic>(
        'services/app/account/GetTenantAccountsAsync', null);

//    print('getTenantAccounts result is ${result.mappedResult}');

    if (result.mappedResult != null) {
      result.mappedResult['userAccounts']['items'].forEach((account) {
        userAccountItems.add(Account.fromJson(account));
      });
      result.mappedResult['otherMembersAccounts']['items']
          .forEach((account) {
        familyAccountItems.add(Account.fromJson(account));
      });
    }

    this.userAccounts = userAccountItems;
    this.familyAccounts = familyAccountItems;
  }
}
