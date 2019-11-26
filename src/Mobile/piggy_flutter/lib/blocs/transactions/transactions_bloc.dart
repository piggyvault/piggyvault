import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/blocs/transaction_summary/transaction_summary.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './transactions.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionSummaryBloc transactionSummaryBloc;
  final TransactionRepository transactionRepository;

  TransactionsBloc(
      {@required this.transactionRepository,
      @required this.transactionSummaryBloc})
      : assert(transactionRepository != null),
        assert(transactionSummaryBloc != null);

  @override
  TransactionsState get initialState => InitialTransactionsState();

  @override
  Stream<TransactionsState> mapEventToState(
    TransactionsEvent event,
  ) async* {
    if (event is SaveTransaction) {
      yield SavingTransaction();
      try {
        await transactionRepository
            .createOrUpdateTransaction(event.transactionEditDto);
        this.transactionSummaryBloc.add(RefreshTransactionSummary());
        yield TransactionSaved();
      } catch (e) {
        yield SaveTransactionError();
      }
    }

    if (event is DoTransfer) {
      yield SavingTransaction();
      try {
        await transactionRepository.transfer(event.transferInput);
        yield TransactionSaved();
      } catch (e) {
        yield SaveTransactionError();
      }
    }
  }
}
