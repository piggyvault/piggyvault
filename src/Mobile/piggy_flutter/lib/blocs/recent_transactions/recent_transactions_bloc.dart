import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/blocs/transaction_detail/bloc.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './bloc.dart';

class RecentTransactionsBloc
    extends Bloc<RecentTransactionsEvent, RecentTransactionsState> {
  final AuthBloc authBloc;
  late StreamSubscription authBlocSubscription;

  final TransactionRepository transactionRepository;

  final TransactionBloc transactionsBloc;
  late StreamSubscription transactionBlocSubscription;

  final TransactionDetailBloc transactionDetailBloc;
  late StreamSubscription transactionDetailBlocSubscription;

  RecentTransactionsBloc(
      {required this.transactionRepository,
      required this.authBloc,
      required this.transactionsBloc,
      required this.transactionDetailBloc})
      : assert(transactionRepository != null),
        assert(authBloc != null),
        assert(transactionsBloc != null),
        assert(transactionDetailBloc != null),
        super(RecentTransactionsEmpty(null)) {
    // TODO: DRY
    authBlocSubscription = authBloc.stream.listen((state) {
      if (state is AuthAuthenticated) {
        add(FetchRecentTransactions(
            input: GetTransactionsInput(
                type: 'tenant',
                accountId: null,
                startDate: DateTime.now().add(Duration(days: -30)),
                endDate: DateTime.now().add(Duration(days: 1)),
                groupBy: TransactionsGroupBy.Date)));
      }
    });

    transactionBlocSubscription = transactionsBloc.stream.listen((state) {
      if (state is TransactionSaved) {
        add(FetchRecentTransactions(
            input: GetTransactionsInput(
                type: 'tenant',
                accountId: null,
                startDate: DateTime.now().add(Duration(days: -30)),
                endDate: DateTime.now().add(Duration(days: 1)),
                groupBy: TransactionsGroupBy.Date)));
      }
    });

    transactionDetailBlocSubscription =
        transactionDetailBloc.stream.listen((state) {
      if (state is TransactionDeleted) {
        add(FetchRecentTransactions(
            input: GetTransactionsInput(
                type: 'tenant',
                accountId: null,
                startDate: DateTime.now().add(Duration(days: -30)),
                endDate: DateTime.now().add(Duration(days: 1)),
                groupBy: TransactionsGroupBy.Date)));
      }
    });
  }

  @override
  Stream<RecentTransactionsState> mapEventToState(
    RecentTransactionsEvent event,
  ) async* {
    if (event is FetchRecentTransactions) {
      yield RecentTransactionsLoading(event.input);
      try {
        final result = await transactionRepository.getTransactions(event.input);

        if (result.isEmpty) {
          yield RecentTransactionsEmpty(event.input);
        } else {
          final DateFormat formatter = DateFormat("EEE, MMM d, ''yy");

          yield RecentTransactionsLoaded(
              allTransactions: result,
              filteredTransactions: result,
              filters: event.input,
              latestTransactionDate: formatter.format(
                  DateTime.parse(result.transactions[0].transactionTime!)));
        }
      } catch (e) {
        yield RecentTransactionsError(event.input);
      }
    } else if (event is GroupRecentTransactions) {
      yield RecentTransactionsLoading(state.filters);
      try {
        final result = await transactionRepository.getTransactions(
            GetTransactionsInput(
                type: 'tenant',
                accountId: null,
                startDate: DateTime.now().add(Duration(days: -30)),
                endDate: DateTime.now().add(Duration(days: 1)),
                groupBy: event.groupBy));

        if (result.isEmpty) {
          yield RecentTransactionsEmpty(state.filters);
        } else {
          final DateFormat formatter = DateFormat("EEE, MMM d, ''yy");

          yield RecentTransactionsLoaded(
              allTransactions: result,
              filteredTransactions: result,
              filters: state.filters,
              latestTransactionDate: formatter.format(
                  DateTime.parse(result.transactions[0].transactionTime!)));
        }
      } catch (e) {
        yield RecentTransactionsError(state.filters);
      }
    } else if (event is FilterRecentTransactions) {
      if (this.state is RecentTransactionsLoaded) {
        if (event.query == null || event.query == "") {
          yield RecentTransactionsLoaded(
              allTransactions:
                  (state as RecentTransactionsLoaded).allTransactions,
              filteredTransactions:
                  (state as RecentTransactionsLoaded).allTransactions,
              latestTransactionDate:
                  (state as RecentTransactionsLoaded).latestTransactionDate,
              filters: state.filters);
        } else {
          var filteredTransactions = (state as RecentTransactionsLoaded)
              .allTransactions
              .transactions
              .where((t) => t.description!
                  .toLowerCase()
                  .contains(event.query.toLowerCase()))
              .toList();
          var filteredTransactionsResult = TransactionsResult(
              sections: transactionRepository.groupTransactions(
                  transactions: filteredTransactions,
                  groupBy: TransactionsGroupBy.Date),
              transactions: filteredTransactions);

          yield RecentTransactionsLoaded(
              allTransactions:
                  (state as RecentTransactionsLoaded).allTransactions,
              filteredTransactions: filteredTransactionsResult,
              latestTransactionDate:
                  (state as RecentTransactionsLoaded).latestTransactionDate,
              filters: state.filters);
        }
      }
    }
  }

  @override
  Future<void> close() {
    authBlocSubscription.cancel();
    transactionBlocSubscription.cancel();
    transactionDetailBlocSubscription.cancel();
    return super.close();
  }
}
