import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class CategorywiseAccountsReportState extends Equatable {
  const CategorywiseAccountsReportState();
  @override
  List<Object?> get props => [null];
}

class CategorywiseAccountsReportLoading
    extends CategorywiseAccountsReportState {}

class CategorywiseAccountsReportLoaded extends CategorywiseAccountsReportState {
  const CategorywiseAccountsReportLoaded({required this.result});

  final List<CategoryReportGroupedListItem> result;

  @override
  List<Object> get props => [result];
}

class CategorywiseAccountsReportError extends CategorywiseAccountsReportState {}
