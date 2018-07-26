import 'dart:async';

import 'package:piggy_flutter/model/category.dart';
import 'package:piggy_flutter/services/category_service.dart';

class CategoryBloc {
  final CategoryService _categoryService = new CategoryService();
  final categoryController = StreamController<List<Category>>();
  Stream<List<Category>> get categories => categoryController.stream;

  CategoryBloc() {
    _categoryService
        .getTenantCategories()
        .then((res) => categoryController.add(_categoryService.categories));
  }

//  void getCategories() async {
//    print('getCategories');
//    await _categoryService.getTenantCategories();
//    categoryController.add(_categoryService.categories);
//  }

  void dispose() {
    categoryController.close();
  }
}
