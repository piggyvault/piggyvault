import 'dart:async';

import 'package:piggy_flutter/model/category.dart';
import 'package:piggy_flutter/services/category_service.dart';
import 'package:rxdart/rxdart.dart';

class CategoryBloc {
  final CategoryService _categoryService = new CategoryService();
  final _categories = BehaviorSubject<List<Category>>();

  Stream<List<Category>> get categories => _categories.stream;

  CategoryBloc() {
//    print("########## CategoryBloc");
    _categoryService.getTenantCategories().then((result) {
      _categories.add(result);
    });
  }

  void dispose() {
    _categories.close();
  }
}
