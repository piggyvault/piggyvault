import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/piggy_api_client.dart';

class CategoryRepository {
  final PiggyApiClient piggyApiClient;

  CategoryRepository({@required this.piggyApiClient})
      : assert(piggyApiClient != null);

  Future<List<Category>> getTenantCategories() async {
    return await piggyApiClient.getTenantCategories();
  }
}
