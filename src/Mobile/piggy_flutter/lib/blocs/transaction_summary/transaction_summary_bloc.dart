import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/blocs/transaction_detail/bloc.dart';
import 'package:piggy_flutter/blocs/transaction_summary/transaction_summary.dart';
import 'dart:developer' as developer;

import 'package:piggy_flutter/repositories/repositories.dart';

class TransactionSummaryBloc
    extends Bloc<TransactionSummaryEvent, TransactionSummaryState> {
  final AuthBloc authBloc;
  StreamSubscription authBlocSubscription;

  final TransactionBloc transactionsBloc;
  StreamSubscription transactionBlocSubscription;

  final TransactionDetailBloc transactionDetailBloc;
  StreamSubscription transactionDetailBlocSubscription;

  final TransactionRepository transactionRepository;

  TransactionSummaryBloc(
      {@required this.transactionRepository,
      @required this.authBloc,
      @required this.transactionsBloc,
      @required this.transactionDetailBloc})
      : assert(transactionRepository != null),
        assert(authBloc != null),
        assert(transactionsBloc != null),
        assert(transactionDetailBloc != null),
        super(TransactionSummaryEmpty()) {
    authBlocSubscription = authBloc.listen((state) {
      if (state is AuthAuthenticated) {
        add(RefreshTransactionSummary());
      }
    });

    transactionBlocSubscription = transactionsBloc.listen((state) {
      if (state is TransactionSaved) {
        add(RefreshTransactionSummary());
      }
    });

    transactionDetailBlocSubscription = transactionDetailBloc.listen((state) {
      if (state is TransactionDeleted) {
        add(RefreshTransactionSummary());
      }
    });
  }

  @override
  Stream<TransactionSummaryState> mapEventToState(
    TransactionSummaryEvent event,
  ) async* {
    if (event is RefreshTransactionSummary) yield TransactionSummaryLoading();
    try {
      final summary =
          await transactionRepository.getTransactionSummary('month');
      yield TransactionSummaryLoaded(summary: summary);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'TransactionSummaryBloc', error: _, stackTrace: stackTrace);
      yield TransactionSummaryError();
    }
  }

  @override
  Future<void> close() {
    authBlocSubscription.cancel();
    transactionDetailBlocSubscription.cancel();
    transactionBlocSubscription.cancel();
    return super.close();
  }
}
