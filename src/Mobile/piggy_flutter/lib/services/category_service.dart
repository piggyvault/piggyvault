import 'dart:async';

import 'package:piggy_flutter/models/api_response.dart';
import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/services/app_service_base.dart';

class CategoryService extends AppServiceBase {
  Future<AjaxResponse<dynamic>> createOrUpdateCategory(Category input) async {
    final result = await rest.postAsync(
        'services/app/Category/CreateOrUpdateCategory',
        {"id": input.id, "name": input.name, "icon": input.icon});

    return result;
  }
}
