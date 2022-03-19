import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './bloc.dart';

class TransactionDetailBloc
    extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  final TransactionRepository transactionRepository;

  TransactionDetailBloc({required this.transactionRepository})
      : assert(transactionRepository != null),
        super(InitialTransactionDetailState());

  @override
  Stream<TransactionDetailState> mapEventToState(
    TransactionDetailEvent event,
  ) async* {
    if (event is DeleteTransaction) {
      yield TransactionDeleting();
      try {
        await transactionRepository.deleteTransaction(event.transactionId);
        yield TransactionDeleted();
      } catch (error) {
        yield TransactionDetailError(errorMessage: error.toString());
      }
    }
  }
}
