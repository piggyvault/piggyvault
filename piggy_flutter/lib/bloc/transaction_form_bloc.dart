import 'dart:async';

import 'package:piggy_flutter/model/api_request.dart';
import 'package:piggy_flutter/model/transaction_edit_dto.dart';
// import 'package:piggy_flutter/model/transaction_form_state.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';

class TransactionFormBloc {
  final _transferController = StreamController<TransferInput>();
  final _transactionService = TransactionService();

  // final _state =
  //     BehaviorSubject<TransactionFormState>(seedValue: TransactionFormState());

  // Stream<TransactionFormState> get state => _state.stream;
  final _state = BehaviorSubject<ApiRequest>();

  Stream<ApiRequest> get state => _state.stream;

  onTransfer(TransferInput input) async {
//    print("########## TransactionBloc transfer");
    // _state.add(TransactionFormBusy());
    ApiRequest request = ApiRequest(isInProcess: true);
    _state.add(request);
    request.type = ApiType.createOrUpdateTransaction;
    await _transactionService.transfer(input);
    request.isInProcess = false;
    _state.add(request);
    // _state.add(TransactionFormSubmitted());
  }

  onSave(TransactionEditDto input) async {
//    print("########## TransactionBloc createOrUpdateTransaction");
    ApiRequest request = ApiRequest(isInProcess: true);
    _state.add(request);
    request.type = ApiType.createOrUpdateTransaction;
    final result = await _transactionService.createOrUpdateTransaction(input);
    request.response = result;
    request.isInProcess = false;
    _state.add(request);
  }

  void dispose() {
    _transferController.close();
    _state.close();
  }
}
