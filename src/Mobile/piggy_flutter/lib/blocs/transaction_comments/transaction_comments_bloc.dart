import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './bloc.dart';

class TransactionCommentsBloc
    extends Bloc<TransactionCommentsEvent, TransactionCommentsState> {
  final TransactionRepository transactionRepository;

  TransactionCommentsBloc({required this.transactionRepository})
      : assert(transactionRepository != null),
        super(TransactionCommentsLoading());

  @override
  Stream<TransactionCommentsState> mapEventToState(
    TransactionCommentsEvent event,
  ) async* {
    if (event is PostTransactionComment) {
      yield TransactionCommentsLoading();
      try {
        await transactionRepository.createOrUpdateTransactionComment(
            event.transactionId, event.comment);
        add(LoadTransactionComments(transactionId: event.transactionId));
      } catch (error) {
        yield TransactionCommentsError(errorMessage: error.toString());
      }
    } else if (event is LoadTransactionComments) {
      yield TransactionCommentsLoading();
      try {
        final comments = await transactionRepository
            .getTransactionComments(event.transactionId);

        yield TransactionCommentsLoaded(comments: comments);
      } catch (error) {
        yield TransactionCommentsError(errorMessage: error.toString());
      }
    }
  }
}
