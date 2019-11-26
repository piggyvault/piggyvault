import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/repositories/account_repository.dart';
import './bloc.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository accountRepository;

  final TransactionBloc transactionsBloc;
  StreamSubscription transactionBlocSubscription;

  AccountBloc(
      {@required this.accountRepository, @required this.transactionsBloc})
      : assert(accountRepository != null),
        assert(transactionsBloc != null) {
    transactionBlocSubscription = transactionsBloc.listen((state) {
      if (state is TransactionSaved) {
        add(RefreshAccount());
      }
    });
  }

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

  @override
  Future<void> close() {
    transactionBlocSubscription.cancel();
    return super.close();
  }
}
