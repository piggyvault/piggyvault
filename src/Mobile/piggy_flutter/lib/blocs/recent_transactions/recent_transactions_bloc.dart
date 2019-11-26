import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './bloc.dart';

class RecentTransactionsBloc
    extends Bloc<RecentTransactionsEvent, RecentTransactionsState> {
  final AuthBloc authBloc;
  StreamSubscription authBlocSubscription;

  final TransactionBloc transactionsBloc;
  StreamSubscription transactionBlocSubscription;
  final TransactionRepository transactionRepository;

  RecentTransactionsBloc(
      {@required this.transactionRepository,
      @required this.authBloc,
      @required this.transactionsBloc})
      : assert(transactionRepository != null),
        assert(authBloc != null),
        assert(transactionsBloc != null) {
    authBlocSubscription = authBloc.listen((state) {
      if (state is AuthAuthenticated) {
        add(LoadRecentTransactions());
      }
    });

    transactionBlocSubscription = transactionsBloc.listen((state) {
      if (state is TransactionSaved) {
        add(LoadRecentTransactions());
      }
    });
  }

  @override
  RecentTransactionsState get initialState => RecentTransactionsEmpty();

  @override
  Stream<RecentTransactionsState> mapEventToState(
    RecentTransactionsEvent event,
  ) async* {
    if (event is LoadRecentTransactions) {
      yield RecentTransactionsLoading();
      try {
        final result = await transactionRepository.getTransactions(
            GetTransactionsInput(
                type: 'tenant',
                accountId: null,
                startDate: DateTime.now().add(Duration(days: -30)),
                endDate: DateTime.now().add(Duration(days: 1)),
                groupBy: TransactionsGroupBy.Date));

        if (result.isEmpty) {
          yield RecentTransactionsEmpty();
        } else {
          final DateFormat formatter = DateFormat("EEE, MMM d, ''yy");

          yield RecentTransactionsLoaded(
              result: result,
              latestTransactionDate: formatter.format(
                  DateTime.parse(result.transactions[0].transactionTime)));
        }
      } catch (e) {
        RecentTransactionsError();
      }
    }

    if (event is GroupRecentTransactions) {
      yield RecentTransactionsLoading();
      try {
        final result = await transactionRepository.getTransactions(
            GetTransactionsInput(
                type: 'tenant',
                accountId: null,
                startDate: DateTime.now().add(Duration(days: -30)),
                endDate: DateTime.now().add(Duration(days: 1)),
                groupBy: event.groupBy));

        if (result.isEmpty) {
          yield RecentTransactionsEmpty();
        } else {
          final DateFormat formatter = DateFormat("EEE, MMM d, ''yy");

          yield RecentTransactionsLoaded(
              result: result,
              latestTransactionDate: formatter.format(
                  DateTime.parse(result.transactions[0].transactionTime)));
        }
      } catch (e) {
        RecentTransactionsError();
      }
    }
  }

  @override
  Future<void> close() {
    authBlocSubscription.cancel();
    transactionBlocSubscription.cancel();
    return super.close();
  }
}
