import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object> get props => [];
}

class CategoriesLoad extends CategoriesEvent {}

class CategorySave extends CategoriesEvent {
  const CategorySave({required this.category}) : assert(category != null);

  final Category category;

  @override
  List<Object> get props => [category];
}
