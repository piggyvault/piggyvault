import 'dart:async';

import 'package:piggy_flutter/services/app_service_base.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends AppServiceBase {
  Future<bool> onLogout() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(UIData.authToken);
  }
}
