import 'package:equatable/equatable.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object> get props => ([]);
}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;

  const CategoriesLoaded([this.categories = const []]);

  @override
  List<Object> get props => [categories];
}

class CategoriesNotLoaded extends CategoriesState {}
