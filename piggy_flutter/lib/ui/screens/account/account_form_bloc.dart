import 'dart:async';

import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/models/api_request.dart';
import 'package:piggy_flutter/models/currency.dart';
import 'package:piggy_flutter/services/account_service.dart';
import 'package:piggy_flutter/ui/screens/account/account_form_model.dart';
import 'package:piggy_flutter/ui/screens/account/account_type_model.dart';
import 'package:rxdart/rxdart.dart';

class AccountFormBloc implements BlocBase {
  AccountFormModel account;

  final AccountService _accountService = AccountService();

  final _currencies = BehaviorSubject<List<Currency>>(seedValue: []);
  Stream<List<Currency>> get currencies => _currencies.stream;

  final _types = BehaviorSubject<List<AccountType>>(seedValue: []);
  Stream<List<AccountType>> get types => _types.stream;

  final _name = BehaviorSubject<String>();
  Stream<String> get name => _name.stream.transform(_validateName);
  Function(String) get changeName => _name.sink.add;

  final _state = BehaviorSubject<ApiRequest>();
  Stream<ApiRequest> get state => _state.stream;

  AccountFormBloc({this.account}) {
    _accountService.getCurrencies().then((result) => _currencies.add(result));
    _accountService.getAccountTypes().then((result) => _types.add(result));
  }

  submit(AccountFormModel formData) async {
    ApiRequest request = ApiRequest(isInProcess: true);
    _state.add(request);

    final validName = _name.value;

    if (account == null) {
      account = AccountFormModel(id: null);
      request.type = ApiType.createAccount;
    } else {
      request.type = ApiType.updateAccount;
    }
    account.name = validName;
    account.currencyId = formData.currencyId;
    account.accountTypeId = formData.accountTypeId;

    final result = await _accountService.createOrUpdateAccount(account);
    request.response = result;
    request.isInProcess = false;
    _state.add(request);
  }

  final StreamTransformer<String, String> _validateName =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (accountName, sink) {
    if (accountName == null || accountName.length == 0) {
      sink.addError('Enter a valid account name');
    } else if (accountName.length > 50) {
      sink.addError('Too long. Account name cannot exceed 50 chars');
    } else {
      sink.add(accountName);
    }
  });

  void dispose() {
    _name?.close();
    _currencies?.close();
    _state?.close();
    _types?.close();
  }
}
