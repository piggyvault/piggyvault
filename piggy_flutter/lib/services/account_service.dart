import 'dart:async';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/models/api_response.dart';
import 'package:piggy_flutter/models/currency.dart';
import 'package:piggy_flutter/services/app_service_base.dart';
import 'package:piggy_flutter/ui/screens/account/account_form_model.dart';
import 'package:piggy_flutter/ui/screens/account/account_type_model.dart';

class AccountService extends AppServiceBase {
  List<Account> userAccounts;
  List<Account> familyAccounts;

  Future<Null> getTenantAccounts() async {
    List<Account> userAccountItems = [];
    List<Account> familyAccountItems = [];
    var result = await rest.postAsync<dynamic>(
        'services/app/account/GetTenantAccountsAsync', null);

    if (result.mappedResult != null) {
      result.mappedResult['userAccounts']['items'].forEach((account) {
        userAccountItems.add(Account.fromJson(account));
      });
      result.mappedResult['otherMembersAccounts']['items'].forEach((account) {
        familyAccountItems.add(Account.fromJson(account));
      });
    }

    this.userAccounts = userAccountItems;
    this.familyAccounts = familyAccountItems;
  }

  Future<Account> getAccountDetails(String accountId) async {
    var result = await rest.postAsync<dynamic>(
        'services/app/account/GetAccountDetails', {"id": accountId});

    if (result.mappedResult != null) {
      return Account.fromJson(result.mappedResult);
    }

    return null;
  }

  Future<List<Currency>> getCurrencies() async {
    List<Currency> currencies = [];
    var result =
        await rest.postAsync('services/app/currency/GetCurrencies', null);

    if (result.mappedResult != null) {
      currencies = result.mappedResult['items']
          .map<Currency>((currency) => Currency.fromJson(currency))
          .toList();
    }
    return currencies;
  }

  Future<List<AccountType>> getAccountTypes() async {
    List<AccountType> output = [];
    var result =
        await rest.postAsync('services/app/account/GetAccountTypes', null);

    if (result.mappedResult != null) {
      output = result.mappedResult['items']
          .map<AccountType>((item) => AccountType.fromJson(item))
          .toList();
    }
    return output;
  }

  Future<ApiResponse<dynamic>> createOrUpdateAccount(
      AccountFormModel input) async {
    print(input);
    final result =
        await rest.postAsync('services/app/category/CreateOrUpdateCategory', {
      // "id": input.id,
      "account": {
        "name": input.name,
        "currencyId": input.currencyId,
        "accountTypeId": input.accountTypeId
      }
    });

    return result.networkServiceResponse;
  }
}
