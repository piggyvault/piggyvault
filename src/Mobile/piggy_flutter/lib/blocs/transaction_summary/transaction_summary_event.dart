import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TransactionSummaryEvent extends Equatable {
  const TransactionSummaryEvent();
  @override
  List<Object> get props => [];
}

class RefreshTransactionSummary extends TransactionSummaryEvent {}
