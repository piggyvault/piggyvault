import 'dart:async';

import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/model/category.dart';
import 'package:piggy_flutter/services/category_service.dart';
import 'package:rxdart/rxdart.dart';

class CategoryBloc implements BlocBase {
  final CategoryService _categoryService = new CategoryService();

  final _categories = BehaviorSubject<List<Category>>();
  final _refreshCategories = PublishSubject<bool>();

  Function(bool) get refreshCategories => _refreshCategories.sink.add;

  Stream<List<Category>> get categories => _categories.stream;

  CategoryBloc() {
//    print("########## CategoryBloc");
    _refreshCategories.stream.listen(onRefreshCategories);
  }

  onRefreshCategories(bool refresh) {
    _categoryService.getTenantCategories().then((result) {
      _categories.add(result);
    });
  }

  void dispose() {
    _categories.close();
    _refreshCategories.close();
  }
}
