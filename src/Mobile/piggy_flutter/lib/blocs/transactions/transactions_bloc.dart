import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './transactions.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository transactionRepository;

  TransactionsBloc({@required this.transactionRepository});

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
