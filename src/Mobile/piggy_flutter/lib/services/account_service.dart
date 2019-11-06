import 'dart:async';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/models/api_response.dart';
import 'package:piggy_flutter/models/currency.dart';
import 'package:piggy_flutter/services/app_service_base.dart';
import 'package:piggy_flutter/screens/account/account_form_model.dart';
import 'package:piggy_flutter/screens/account/account_type_model.dart';

class AccountService extends AppServiceBase {
  List<Account> userAccounts;
  List<Account> familyAccounts;

  Future<Null> getTenantAccounts() async {
    List<Account> userAccountItems = [];
    List<Account> familyAccountItems = [];
    var result = await rest.getAsync<dynamic>(
        'services/app/account/GetTenantAccountsAsync');

    if (result.success) {
      result.result['userAccounts']['items'].forEach((account) {
        userAccountItems.add(Account.fromJson(account));
      });
      result.result['otherMembersAccounts']['items'].forEach((account) {
        familyAccountItems.add(Account.fromJson(account));
      });
    }

    this.userAccounts = userAccountItems;
    this.familyAccounts = familyAccountItems;
  }

  Future<AccountFormModel> getAccountForEdit(String id) async {
    var result = await rest
        .getAsync('services/app/account/getAccountForEdit?id=$id');

    if (result.success) {
      return AccountFormModel.fromJson(result.result);
    }
    return null;
  }

  Future<Account> getAccountDetails(String accountId) async {
    var result = await rest.getAsync<dynamic>(
        'services/app/account/GetAccountDetails?id=$accountId');

    if (result.success) {
      return Account.fromJson(result.result);
    }

    return null;
  }

  Future<List<Currency>> getCurrencies() async {
    List<Currency> currencies = [];
    var result =
        await rest.getAsync('services/app/currency/GetCurrencies');

    if (result.success) {
      currencies = result.result['items']
          .map<Currency>((currency) => Currency.fromJson(currency))
          .toList();
    }
    return currencies;
  }

  Future<List<AccountType>> getAccountTypes() async {
    List<AccountType> output = [];
    var result =
        await rest.getAsync('services/app/account/GetAccountTypes');

    if (result.success) {
      output = result.result['items']
          .map<AccountType>((item) => AccountType.fromJson(item))
          .toList();
    }
    return output;
  }

  Future<AjaxResponse<dynamic>> createOrUpdateAccount(
      AccountFormModel input) async {
    print(input);
    final result =
        await rest.postAsync('services/app/account/CreateOrUpdateAccount', {
      "account": {
        "id": input.id,
        "name": input.name,
        "currencyId": input.currencyId,
        "accountTypeId": input.accountTypeId
      }
    });

    return result;
  }
}
