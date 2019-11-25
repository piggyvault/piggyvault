import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class AccountTransactionsState extends Equatable {
  const AccountTransactionsState();
  @override
  List<Object> get props => [];
}

class AccountTransactionsEmpty extends AccountTransactionsState {}

class AccountTransactionsLoading extends AccountTransactionsState {}

class AccountTransactionsLoaded extends AccountTransactionsState {
  final TransactionsResult result;

  AccountTransactionsLoaded({@required this.result});
}

class AccountTransactionsError extends AccountTransactionsState {}
