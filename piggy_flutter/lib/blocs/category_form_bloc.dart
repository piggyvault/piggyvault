import 'dart:async';

import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/models/api_request.dart';
import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/services/category_service.dart';
import 'package:rxdart/rxdart.dart';

class CategoryFormBloc implements BlocBase {
  Category category;
  CategoryFormBloc({this.category}) {
    // print('$category');
    if (category != null) {
      changeCategoryName(category.name);
    }
  }

  final CategoryService _categoryService = CategoryService();

  final _categoryName = BehaviorSubject<String>();
  Stream<String> get categoryName =>
      _categoryName.stream.transform(_validateCategoryName);
  Function(String) get changeCategoryName => _categoryName.sink.add;

  final _state = BehaviorSubject<ApiRequest>();
  Stream<ApiRequest> get state => _state.stream;

  submit() async {
    ApiRequest request = ApiRequest(isInProcess: true);
    _state.add(request);

    final validCategoryName = _categoryName.value;

    if (category == null) {
      category = Category(id: null, icon: 'icon-question');
      request.type = ApiType.createCategory;
    } else {
      request.type = ApiType.updateCategory;
    }

    category.name = validCategoryName;
    final result = await _categoryService.createOrUpdateCategory(category);
    request.response = result;
    request.isInProcess = false;
    _state.add(request);
  }

  final StreamTransformer<String, String> _validateCategoryName =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (categoryName, sink) {
    if (categoryName == null || categoryName.length == 0) {
      sink.addError('Enter a valid category name');
    } else if (categoryName.length > 50) {
      sink.addError('Too long. Category name cannot exceed 50 chars');
    } else {
      sink.add(categoryName);
    }
  });

  void dispose() {
    _categoryName.close();
    _state.close();
  }
}
