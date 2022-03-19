import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class CategorywiseRecentMonthsReportState extends Equatable {
  const CategorywiseRecentMonthsReportState();
  @override
  List<Object?> get props => [null];
}

class CategorywiseRecentMonthsReportLoading
    extends CategorywiseRecentMonthsReportState {}

class CategorywiseRecentMonthsReportLoaded
    extends CategorywiseRecentMonthsReportState {
  const CategorywiseRecentMonthsReportLoaded({required this.result});

  final List<CategoryWiseRecentMonthsReportItem> result;

  @override
  List<Object> get props => [result];
}

class CategorywiseRecentMonthsReportError
    extends CategorywiseRecentMonthsReportState {}
