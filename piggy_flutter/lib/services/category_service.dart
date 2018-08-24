import 'dart:async';

import 'package:piggy_flutter/models/api_response.dart';
import 'package:piggy_flutter/models/category.dart';
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

  Future<ApiResponse<dynamic>> createOrUpdateCategory(Category input) async {
    final result = await rest.postAsync(
        'services/app/category/CreateOrUpdateCategory',
        {"id": input.id, "name": input.name, "icon": input.icon});

    return result.networkServiceResponse;
  }
}
