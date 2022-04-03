import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PiggyApiClient {
  PiggyApiClient({required this.httpClient}) : assert(httpClient != null);

  static const String baseUrl = 'https://piggyvault.abhith.net';

  final http.Client httpClient;

  // ACCOUNT
  Future<AccountFormModel?> getAccountForEdit(String? id) async {
    final ApiResponse<dynamic> result = await getAsync<dynamic>(
        '$baseUrl/api/services/app/account/getAccountForEdit?id=$id');

    if (result.success!) {
      return AccountFormModel.fromJson(result.result);
    }

    return null;
  }

  // CATEGORY
  Future<bool> createOrUpdateCategory(Category input) async {
    final response = await postAsync<dynamic>(
        '$baseUrl/api/services/app/Category/CreateOrUpdateCategory',
        {'id': input.id, 'name': input.name, 'icon': input.icon});
    if (!response.success!) {
      throw Exception(response.error);
    }

    return true;
  }

  Future<IsTenantAvailableResult> isTenantAvailable(String tenancyName) async {
    final tenantUrl = '$baseUrl/api/services/app/Account/IsTenantAvailable';
    final response =
        await this.postAsync<dynamic>(tenantUrl, {"tenancyName": tenancyName});

    if (!response.success!) {
      throw Exception('invalid credentials');
    }

    return IsTenantAvailableResult.fromJson(response.result);
  }

  Future<AuthenticateResult> authenticate(
      {required String usernameOrEmailAddress,
      required String password}) async {
    final loginUrl = '$baseUrl/api/TokenAuth/Authenticate';
    final loginResult = await this.postAsync<dynamic>(loginUrl, {
      "usernameOrEmailAddress": usernameOrEmailAddress,
      "password": password,
      "rememberClient": true
    });

    if (!loginResult.success!) {
      throw Exception(loginResult.error);
    }
    return AuthenticateResult.fromJson(loginResult.result);
  }

  Future<LoginInformationResult?> getCurrentLoginInformations() async {
    const String userUrl =
        '$baseUrl/api/services/app/session/GetCurrentLoginInformations';
    final ApiResponse<dynamic> response = await getAsync<dynamic>(userUrl);

    if (response.success! && response.result['user'] != null) {
      return LoginInformationResult(
          user: User.fromJson(response.result['user']),
          tenant: Tenant.fromJson(response.result['tenant']));
    }

    return null;
  }

  Future<TransactionSummary> getTransactionSummary(String duration) async {
    var result = await getAsync<dynamic>(
        '$baseUrl/api/services/app/Transaction/GetSummary?duration=$duration');

    return TransactionSummary.fromJson(result.result);
  }

  Future<TenantAccountsResult> getTenantAccounts() async {
    List<Account> userAccountItems = [];
    List<Account> familyAccountItems = [];
    var result = await getAsync<dynamic>(
        '$baseUrl/api/services/app/account/GetTenantAccounts');

    if (result.success!) {
      result.result['userAccounts']['items'].forEach((account) {
        userAccountItems.add(Account.fromJson(account));
      });
      result.result['otherMembersAccounts']['items'].forEach((account) {
        familyAccountItems.add(Account.fromJson(account));
      });
    }

    return TenantAccountsResult(
        familyAccounts: familyAccountItems, userAccounts: userAccountItems);
  }

  Future<List<Category>> getTenantCategories() async {
    List<Category> tenantCategories = [];

    var result = await getAsync(
        '$baseUrl/api/services/app/Category/GetTenantCategories');

    if (result.success!) {
      result.result['items'].forEach(
          (category) => tenantCategories.add(Category.fromJson(category)));
    }
    return tenantCategories;
  }

  Future<ApiResponse<dynamic>> createOrUpdateTransaction(
      TransactionEditDto input) async {
    final result = await postAsync(
        '$baseUrl/api/services/app/transaction/CreateOrUpdateTransaction', {
      "id": input.id,
      "description": input.description,
      "amount": input.amount,
      "categoryId": input.categoryId,
      "accountId": input.accountId,
      "transactionTime": input.transactionTime
    });

    return result;
  }

  Future<ApiResponse<dynamic>> transfer(TransferInput input) async {
    final result =
        await postAsync('$baseUrl/api/services/app/transaction/transfer', {
      "id": input.id,
      "description": input.description,
      "amount": input.amount,
      "toAmount": input.toAmount,
      "categoryId": input.categoryId,
      "accountId": input.accountId,
      "toAccountId": input.toAccountId,
      "transactionTime": input.transactionTime
    });

    return result;
  }

  Future<List<Transaction>> getTransactions(GetTransactionsInput input) async {
    final List<Transaction> transactions = <Transaction>[];

    String params = '';

    if (input.type != null) {
      params += 'type=${input.type}';
    }

    if (input.accountId != null) {
      params += '&accountId=${input.accountId}';
    }

    if (input.categoryId != null) {
      params += '&categoryId=${input.categoryId}';
    }

    if (input.startDate != null && input.startDate.toString() != '')
      params += '&startDate=${input.startDate}';

    if (input.endDate != null && input.endDate.toString() != '')
      params += '&endDate=${input.endDate}';

    final ApiResponse<dynamic> result = await getAsync<dynamic>(
        '$baseUrl/api/services/app/transaction/GetTransactions?$params');

    if (result.success!) {
      result.result['items'].forEach((dynamic transaction) {
        transactions.add(Transaction.fromJson(transaction));
      });
    }
    return transactions;
  }

  Future<Account> getAccountDetails(String accountId) async {
    var result = await getAsync<dynamic>(
        '$baseUrl/api/services/app/account/GetAccountDetails?id=$accountId');

    return Account.fromJson(result.result);
  }

  Future<ApiResponse<dynamic>> createOrUpdateAccount(
      AccountFormModel input) async {
    final result = await postAsync(
        '$baseUrl/api/services/app/account/CreateOrUpdateAccount', {
      "account": {
        "id": input.id,
        "name": input.name,
        "currencyId": input.currencyId,
        "accountTypeId": input.accountTypeId,
        "isArchived": input.isArchived
      }
    });

    return result;
  }

  Future<List<Currency>> getCurrencies() async {
    var result =
        await getAsync('$baseUrl/api/services/app/currency/GetCurrencies');

    return result.result['items']
        .map<Currency>((currency) => Currency.fromJson(currency))
        .toList();
  }

  Future<List<AccountType>> getAccountTypes() async {
    var result = await getAsync<dynamic>(
        '$baseUrl/api/services/app/account/GetAccountTypes');

    return result.result['items']
        .map<AccountType>((item) => AccountType.fromJson(item))
        .toList();
  }

  // Reports
  Future<List<CategoryWiseRecentMonthsReportItem>>
      getCategoryWiseTransactionSummaryHistory() async {
    List<CategoryWiseRecentMonthsReportItem> data = [];
    var result = await getAsync(
        '$baseUrl/api/services/app/Report/GetCategoryWiseTransactionSummaryHistory?numberOfIteration=3&periodOfIteration=month&typeOfTransaction=expense');

    if (result.success!) {
      result.result['items'].forEach((item) =>
          data.add(CategoryWiseRecentMonthsReportItem.fromJson(item)));
    }
    return data;
  }

  Future<List<CategoryReportListDto>> getCategoryReport(
      GetCategoryReportInput input) async {
    final List<CategoryReportListDto> data = [];
    final ApiResponse result = await getAsync<dynamic>(
        '$baseUrl/api/services/app/Report/GetCategoryReport?startDate=${input.startDate}&endDate=${input.endDate}');

    if (result.success!) {
      result.result['items']
          .forEach((item) => data.add(CategoryReportListDto.fromJson(item)));
    }
    return data;
  }

  // Transaction
  Future<void> deleteTransaction(String id) async {
    await deleteAsync<dynamic>(
        '$baseUrl/api/services/app/transaction/DeleteTransaction?id=$id');
  }

  Future<void> createOrUpdateTransactionComment(
      String transactionId, String content) async {
    await postAsync<dynamic>(
        '$baseUrl/api/services/app/transaction/CreateOrUpdateTransactionComment',
        {
          "transactionId": transactionId,
          "content": content,
        });
  }

  Future<List<TransactionComment>> getTransactionComments(String id) async {
    List<TransactionComment> comments = [];
    var result = await getAsync<dynamic>(
        '$baseUrl/api/services/app/transaction/GetTransactionComments?id=$id');
    if (result.success!) {
      result.result['items'].forEach((comment) {
        comments.add(TransactionComment.fromJson(comment));
      });
    }

    return comments;
  }

  // USER
  Future<UserSettings> getUserSettings() async {
    var result =
        await getAsync<dynamic>('$baseUrl/api/services/app/User/GetSettings');

    return UserSettings.fromJson(result.result);
  }

  Future<void> changeDefaultCurrency(String currencyCode) async {
    await postAsync<dynamic>(
        '$baseUrl/api/services/app/User/ChangeDefaultCurrency',
        {"currencyCode": currencyCode});
  }

// utils

  Future<ApiResponse<T?>> getAsync<T>(String resourcePath) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(UIData.authToken);
    var tenantId = prefs.getInt(UIData.tenantId);
    var url = Uri.parse(resourcePath);

    var response = await this.httpClient.get(url, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Piggy-TenantId': tenantId.toString()
    });
    return processResponse<T>(response);
  }

  Future<ApiResponse<T?>> postAsync<T>(
      String resourcePath, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(UIData.authToken);
    var tenantId = prefs.getInt(UIData.tenantId);

    var content = json.encoder.convert(data);
    Map<String, String> headers;

    if (token == null) {
      headers = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Piggy-TenantId': tenantId.toString()
      };
    } else {
      headers = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Piggy-TenantId': tenantId.toString()
      };
    }

    var url = Uri.parse(resourcePath);

    var response = await http.post(url, body: content, headers: headers);
    return processResponse<T>(response);
  }

  Future<ApiResponse<T?>> deleteAsync<T>(String resourcePath) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(UIData.authToken);
    var tenantId = prefs.getInt(UIData.tenantId);

    Map<String, String> headers;

    if (token == null) {
      // TODO: throw exception
      headers = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Piggy-TenantId': tenantId.toString()
      };
    } else {
      headers = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Piggy-TenantId': tenantId.toString()
      };
    }

    var url = Uri.parse(resourcePath);
    var response = await http.delete(url, headers: headers);
    return processResponse<T>(response);
  }

  ApiResponse<T?> processResponse<T>(http.Response response) {
    try {
      // if (!((response.statusCode < 200) ||
      //     (response.statusCode >= 300) ||
      //     (response.body == null))) {
      var jsonResult = response.body;
      dynamic parsedJson = jsonDecode(jsonResult);

      // print(jsonResult);

      var output = ApiResponse<T?>(
        result: parsedJson["result"],
        success: parsedJson["success"],
        unAuthorizedRequest: parsedJson['unAuthorizedRequest'],
      );

      if (!output.success!) {
        output.error = parsedJson["error"]["message"];
      }
      return output;
    } catch (e) {
      return ApiResponse<T?>(
          result: null,
          success: false,
          unAuthorizedRequest: false,
          error: 'Something went wrong. Please try again');
    }
  }
}
