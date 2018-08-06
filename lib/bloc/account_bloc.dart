import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/services/account_service.dart';

class AccountBloc {

  List<Account> userAccountList;

  final AccountService _accountService = new AccountService();

  final _accountsRefresh = PublishSubject<bool>();

  Function(bool) get accountsRefresh => _accountsRefresh.sink.add;

  final _userAccounts = BehaviorSubject<List<Account>>();
  final _familyAccounts = BehaviorSubject<List<Account>>();

  Stream<List<Account>> get userAccounts => _userAccounts.stream;

  Stream<List<Account>> get familyAccounts => _familyAccounts.stream;

  AccountBloc() {
    _accountsRefresh.stream.listen(getTenantAccounts);
  }

  Future<Null> getTenantAccounts(bool done) async {
//    print("########## AccountBloc getTenantAccounts");
    await _accountService.getTenantAccounts();
    userAccountList = _accountService.userAccounts;
    _userAccounts.add(userAccountList);
    _familyAccounts.add(_accountService.familyAccounts);
  }

  void dispose() {
    _accountsRefresh.close();
    _userAccounts.close();
    _familyAccounts.close();
  }
}
