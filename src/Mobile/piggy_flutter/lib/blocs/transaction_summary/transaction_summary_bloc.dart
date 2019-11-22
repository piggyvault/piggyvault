import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/blocs/transaction_summary/transaction_summary.dart';
import 'dart:developer' as developer;

import 'package:piggy_flutter/repositories/repositories.dart';

class TransactionSummaryBloc
    extends Bloc<TransactionSummaryEvent, TransactionSummaryState> {
  final TransactionRepository transactionRepository;

  TransactionSummaryBloc({@required this.transactionRepository})
      : assert(transactionRepository != null);

  @override
  TransactionSummaryState get initialState => TransactionSummaryEmpty();

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
}
