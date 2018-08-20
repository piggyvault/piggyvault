import 'dart:async';

import 'package:piggy_flutter/model/category.dart';
import 'package:piggy_flutter/services/app_service_base.dart';

class CategoryService extends AppServiceBase {
  Future<List<Category>> getTenantCategories() async {
    List<Category> tenantCategories = [];

    var result =
        await rest.postAsync('services/app/category/GetTenantCategories', null);

    if (result.mappedResult != null) {
      result.mappedResult['items'].forEach(
          (category) => tenantCategories.add(Category.fromJson(category)));
    }
    return tenantCategories;
  }
}
