import 'dart:async';

import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/models/api_request.dart';
import 'package:piggy_flutter/models/transaction_edit_dto.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';

class TransactionFormBloc implements BlocBase {
  final _transactionService = TransactionService();
  final _transferController = StreamController<TransferInput>();
  final _state = BehaviorSubject<ApiRequest>();

  Stream<ApiRequest> get state => _state.stream;

  onTransfer(TransferInput input) async {
//    print("########## TransactionBloc transfer");
    ApiRequest request = ApiRequest(isInProcess: true);
    _state.add(request);
    request.type = ApiType.createOrUpdateTransaction;
    final result = await _transactionService.transfer(input);
    request.response = result;
    request.isInProcess = false;
    _state.add(request);
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
