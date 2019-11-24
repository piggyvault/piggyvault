import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class RecentTransactionsEvent extends Equatable {
  const RecentTransactionsEvent();

  @override
  List<Object> get props => [];
}

class GroupRecentTransactions extends RecentTransactionsEvent {
  final TransactionsGroupBy groupBy;

  GroupRecentTransactions({@required this.groupBy}) : assert(groupBy != null);

  @override
  List<Object> get props => [groupBy];
}

class LoadRecentTransactions extends RecentTransactionsEvent {}
