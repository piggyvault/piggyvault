import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/piggy_api_client.dart';

class CategoryRepository {
  CategoryRepository({required this.piggyApiClient})
      : assert(piggyApiClient != null);

  final PiggyApiClient piggyApiClient;

  Future<List<Category>> getTenantCategories() async {
    return await piggyApiClient.getTenantCategories();
  }

  Future<bool> createOrUpdateCategory(Category input) async {
    return await piggyApiClient.createOrUpdateCategory(input);
  }
}
