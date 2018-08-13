import 'dart:async';

import 'package:piggy_flutter/model/transaction_edit_dto.dart';
import 'package:piggy_flutter/services/transaction_service.dart';

class TransactionFormBloc {
  final _transferController = StreamController<TransferInput>();
  final _transactionService = TransactionService();

  onTransfer(TransferInput input) async {
//    print("########## TransactionBloc transfer");
    await _transactionService.transfer(input);
  }

  onSave(TransactionEditDto input) async {
//    print("########## TransactionBloc createOrUpdateTransaction");
    await _transactionService.createOrUpdateTransaction(input);
  }

  void dispose() {
    _transferController.close();
  }
}
