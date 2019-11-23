import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import 'package:piggy_flutter/blocs/accounts/accounts.dart';
import 'package:piggy_flutter/repositories/repositories.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final AccountRepository accountRepository;

  AccountsBloc({@required this.accountRepository});

  @override
  AccountsState get initialState => AccountsLoading();

  @override
  Stream<AccountsState> mapEventToState(
    AccountsEvent event,
  ) async* {
    if (event is LoadAccounts) {
      yield* _mapLoadAccountsToState();
    }
  }

  Stream<AccountsState> _mapLoadAccountsToState() async* {
    try {
      final allAccounts = await accountRepository.getTenantAccounts();
      yield AccountsLoaded(
          allAccounts.userAccounts, allAccounts.familyAccounts);
    } catch (e) {
      AccountsNotLoaded();
    }
  }
}
