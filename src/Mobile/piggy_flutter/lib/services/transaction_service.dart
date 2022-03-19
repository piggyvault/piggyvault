import 'dart:async';

import 'package:piggy_flutter/models/transaction_edit_dto.dart';
import 'package:piggy_flutter/services/app_service_base.dart';

class TransactionService extends AppServiceBase {
  Future<TransactionEditDto?> getTransactionForEdit(String? id) async {
    var result = await rest.getAsync<dynamic>(
        'services/app/transaction/GetTransactionForEdit?id=$id');

    if (result.success != null) {
      return TransactionEditDto.fromJson(result.result);
    }

    return null;
  }
}
