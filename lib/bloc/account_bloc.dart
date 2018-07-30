import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/services/account_service.dart';

class AccountBloc {
  List<Account> userAccountList;
  List<Account> familyAccountList;
  final AccountService _accountService = new AccountService();

  final accountsRefreshController = StreamController<bool>();

  Sink<bool> get accountsRefresh => accountsRefreshController.sink;

  final _userAccounts = BehaviorSubject<List<Account>>();
  final _familyAccounts = BehaviorSubject<List<Account>>();

  Stream<List<Account>> get userAccounts => _userAccounts.stream;

  Stream<List<Account>> get familyAccounts => _familyAccounts.stream;

  AccountBloc() {
    print("########## AccountBloc");
    getTenantAccounts(true);
    accountsRefreshController.stream.listen(getTenantAccounts);
  }

  void getTenantAccounts(bool done) async {
    print("########## AccountBloc getTenantAccounts");
    await _accountService.getTenantAccounts();
    userAccountList = _accountService.userAccounts;
    familyAccountList = _accountService.familyAccounts;
    _userAccounts.add(userAccountList);
    _familyAccounts.add(familyAccountList);
  }

  void dispose() {
    accountsRefreshController.close();
    _userAccounts.close();
    _familyAccounts.close();
  }
}
