import 'dart:async';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/services/account_service.dart';

class AccountBloc implements BlocBase {
  List<Account> userAccountList;

  final AccountService _accountService = new AccountService();

  final _accountsRefresh = PublishSubject<bool>();
  final _userAccounts = BehaviorSubject<List<Account>>();
  final _familyAccounts = BehaviorSubject<List<Account>>();

  Function(bool) get accountsRefresh => _accountsRefresh.sink.add;

  Stream<List<Account>> get userAccounts => _userAccounts.stream;
  Stream<List<Account>> get familyAccounts => _familyAccounts.stream;

  AccountBloc() {}

  void dispose() {
    _accountsRefresh.close();
    _userAccounts.close();
    _familyAccounts.close();
  }
}
