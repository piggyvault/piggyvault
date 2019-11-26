import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import 'package:piggy_flutter/blocs/accounts/accounts.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/repositories/repositories.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final AccountRepository accountRepository;

  final AuthBloc authBloc;
  StreamSubscription authBlocSubscription;

  final TransactionBloc transactionsBloc;
  StreamSubscription transactionBlocSubscription;

  AccountsBloc(
      {@required this.accountRepository,
      @required this.authBloc,
      @required this.transactionsBloc})
      : assert(accountRepository != null),
        assert(authBloc != null),
        assert(transactionsBloc != null) {
    authBlocSubscription = authBloc.listen((state) {
      if (state is AuthAuthenticated) {
        add(LoadAccounts());
      }
    });

    transactionBlocSubscription = transactionsBloc.listen((state) {
      if (state is TransactionSaved) {
        add(LoadAccounts());
      }
    });
  }

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

  @override
  Future<void> close() {
    authBlocSubscription.cancel();
    transactionBlocSubscription.cancel();
    return super.close();
  }
}
