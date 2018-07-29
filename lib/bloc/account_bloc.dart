import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/services/account_service.dart';

class AccountBloc {
  final accountController = StreamController<bool>();
  final AccountService _accountService = new AccountService();

  Sink<bool> get refreshAccounts => accountController.sink;

  final userAccountResultController = BehaviorSubject<List<Account>>();
  final familyAccountResultController = BehaviorSubject<List<Account>>();

  Stream<List<Account>> get userAccounts => userAccountResultController.stream;

  Stream<List<Account>> get familyAccounts =>
      familyAccountResultController.stream;

  AccountBloc() {
    print("########## AccountBloc");
    accountController.stream.listen(getTenantAccounts);
  }

  void getTenantAccounts(bool done) async {
    print("########## AccountBloc getTenantAccounts");
    await _accountService.getTenantAccounts();
    userAccountResultController.add(_accountService.userAccounts);
    familyAccountResultController.add(_accountService.familyAccounts);
  }

  void dispose() {
    accountController.close();
    userAccountResultController.close();
    familyAccountResultController.close();
  }
}
