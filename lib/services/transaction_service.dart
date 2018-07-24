import 'dart:async';

import 'package:piggy_flutter/services/app_service_base.dart';
import 'package:piggy_flutter/services/network_service_response.dart';

class GetTransactionsInput {
  String type;
  String accountId;
  String startDate;
  String endDate;
  String query;

  GetTransactionsInput(
      String _type, String _accountId, String _startDate, String _endDate) {
    type = _type;
    accountId = _accountId;
    startDate = _startDate;
    endDate = _endDate;
  }
}

class TransactionService extends AppServiceBase {
  Future<NetworkServiceResponse<dynamic>> getTransactions(
      GetTransactionsInput input) async {
    var result = await rest
        .postAsync<dynamic>('services/app/transaction/GetTransactionsAsync', {
      "type": input.type,
      "accountId": input.accountId,
      "startDate": input.startDate,
      "endDate": input.endDate
    });

//    print('getTransactions result is ${result.mappedResult}');

    if (result.mappedResult != null) {
      return new NetworkServiceResponse(
        content: result.mappedResult["result"],
        success: result.networkServiceResponse.success,
      );
    }
    return new NetworkServiceResponse(
        success: result.networkServiceResponse.success,
        message: result.networkServiceResponse.message);
  }
}
