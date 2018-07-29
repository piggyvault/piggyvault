import 'dart:async';

import 'package:piggy_flutter/model/category.dart';
import 'package:piggy_flutter/services/category_service.dart';
import 'package:rxdart/rxdart.dart';

class CategoryBloc {
  List<Category> allCategories;

  final CategoryService _categoryService = new CategoryService();
  final categorySubject = BehaviorSubject<List<Category>>();

  Stream<List<Category>> get categories => categorySubject.stream;

  CategoryBloc() {
    print("########## CategoryBloc");
    _categoryService.getTenantCategories().then((result) {
      allCategories = result;
      categorySubject.add(allCategories);
    });
  }

//  void getCategories() async {
//    print('getCategories');
//    await _categoryService.getTenantCategories();
//    categoryController.add(_categoryService.categories);
//  }

  void dispose() {
    categorySubject.close();
  }
}
