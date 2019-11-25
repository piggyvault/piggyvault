import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/repositories/account_repository.dart';
import './bloc.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository accountRepository;

  AccountBloc({@required this.accountRepository})
      : assert(accountRepository != null);

  @override
  AccountState get initialState => AccountEmpty();

  @override
  Stream<AccountState> mapEventToState(
    AccountEvent event,
  ) async* {
    if (event is FetchAccount) {
      yield AccountLoading();

      try {
        var account =
            await accountRepository.getAccountDetails(event.accountId);

        yield AccountLoaded(account: account);
      } catch (e) {
        yield AccountFetchError();
      }
    }
  }
}
