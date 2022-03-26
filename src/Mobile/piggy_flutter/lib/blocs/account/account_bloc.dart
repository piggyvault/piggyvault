import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/blocs/transaction_detail/bloc.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/repositories/account_repository.dart';
import './bloc.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc(
      {required this.accountRepository,
      required this.transactionsBloc,
      required this.transactionDetailBloc})
      : super(AccountEmpty(null)) {
    transactionBlocSubscription = transactionsBloc.stream.listen((state) {
      if (state is TransactionSaved) {
        add(RefreshAccount());
      }
    });

    transactionDetailBlocSubscription =
        transactionDetailBloc.stream.listen((state) {
      if (state is TransactionDeleted) {
        add(RefreshAccount());
      }
    });
  }

  final AccountRepository accountRepository;

  final TransactionBloc transactionsBloc;
  late StreamSubscription transactionBlocSubscription;

  final TransactionDetailBloc transactionDetailBloc;
  late StreamSubscription transactionDetailBlocSubscription;

  @override
  Stream<AccountState> mapEventToState(
    AccountEvent event,
  ) async* {
    if (event is FetchAccount) {
      yield AccountLoading(event.accountId);

      try {
        final Account account =
            await accountRepository.getAccountDetails(event.accountId);

        yield AccountLoaded(account: account);
      } catch (e) {
        yield AccountFetchError(event.accountId);
      }
    }

    if (event is RefreshAccount) {
      add(FetchAccount(accountId: state.accountId!));
    }
  }

  @override
  Future<void> close() {
    transactionDetailBlocSubscription.cancel();
    transactionBlocSubscription.cancel();
    return super.close();
  }
}
