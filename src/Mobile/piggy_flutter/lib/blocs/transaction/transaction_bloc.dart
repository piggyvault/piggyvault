import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './transaction.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;

  TransactionBloc({
    required this.transactionRepository,
  })  : assert(transactionRepository != null),
        super(InitialTransactionsState());

  @override
  Stream<TransactionState> mapEventToState(
    TransactionEvent event,
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
