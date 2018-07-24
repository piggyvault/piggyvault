import 'dart:async';

import 'package:piggy_flutter/services/app_service_base.dart';
import 'package:piggy_flutter/services/network_service_response.dart';

class AccountService extends AppServiceBase {
  Future<NetworkServiceResponse<dynamic>> getTenantAccounts() async {
    var result = await rest.postAsync<dynamic>(
        'services/app/account/GetTenantAccountsAsync', null);

    print('getTenantAccounts result is ${result.mappedResult}');

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
