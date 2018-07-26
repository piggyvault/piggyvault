import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/services/account_service.dart';

class AccountBloc {
  final accountController = StreamController<AccountService>();

  final userAccountResultController = BehaviorSubject<List<Account>>();
  final familyAccountResultController = BehaviorSubject<List<Account>>();

  Sink<AccountService> get accounts => accountController.sink;

  Stream<List<Account>> get userAccounts => userAccountResultController.stream;

  Stream<List<Account>> get familyAccounts =>
      familyAccountResultController.stream;

  AccountBloc() {
    accountController.stream.listen(apiCall);
  }

  void apiCall(AccountService accountService) async {
//    print('apiCall');
    await accountService.getTenantAccounts();
    userAccountResultController.add(accountService.userAccounts);
    familyAccountResultController.add(accountService.familyAccounts);
  }

  void dispose() {
    accountController.close();
    userAccountResultController.close();
    familyAccountResultController.close();
  }
}
