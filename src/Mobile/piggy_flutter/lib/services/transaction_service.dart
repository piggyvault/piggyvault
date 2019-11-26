import 'dart:async';

import 'package:piggy_flutter/models/api_response.dart';
import 'package:piggy_flutter/models/transaction_comment.dart';
import 'package:piggy_flutter/models/transaction_edit_dto.dart';
import 'package:piggy_flutter/services/app_service_base.dart';

class TransactionService extends AppServiceBase {
  Future<TransactionEditDto> getTransactionForEdit(String id) async {
    var result = await rest.getAsync<dynamic>(
        'services/app/transaction/GetTransactionForEdit?id=$id');

    if (result.success != null) {
      return TransactionEditDto.fromJson(result.result);
    }

    return null;
  }

  Future<List<TransactionComment>> getTransactionComments(String id) async {
    var comments = List<TransactionComment>();
    var result = await rest.getAsync<dynamic>(
        'services/app/transaction/GetTransactionComments?id=$id');
    if (result.success) {
      result.result['items'].forEach((comment) {
        comments.add(TransactionComment.fromJson(comment));
      });
    }

    return comments;
  }

  Future<ApiResponse<dynamic>> deleteTransaction(String id) async {
    final result =
        await rest.postAsync('services/app/transaction/DeleteTransaction', {
      "id": id,
    });

    return result;
  }

  Future<Null> saveTransactionComment(
      String transactionId, String content) async {
    await rest.postAsync(
        'services/app/transaction/CreateOrUpdateTransactionComment', {
      "transactionId": transactionId,
      "content": content,
    });
  }
}
