import 'dart:async';

import 'package:piggy_flutter/model/transaction_edit_dto.dart';
import 'package:piggy_flutter/model/transaction_form_state.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';

class TransactionFormBloc {
  final _transferController = StreamController<TransferInput>();
  final _transactionService = TransactionService();

  final _state =
      BehaviorSubject<TransactionFormState>(seedValue: TransactionFormState());

  Stream<TransactionFormState> get state => _state.stream;

  onTransfer(TransferInput input) async {
//    print("########## TransactionBloc transfer");
    _state.add(TransactionFormBusy());
    await _transactionService.transfer(input);
    _state.add(TransactionFormSubmitted());
  }

  onSave(TransactionEditDto input) async {
//    print("########## TransactionBloc createOrUpdateTransaction");
    _state.add(TransactionFormBusy());
    await _transactionService.createOrUpdateTransaction(input);
    _state.add(TransactionFormSubmitted());
  }

  void dispose() {
    _transferController.close();
    _state.close();
  }
}
