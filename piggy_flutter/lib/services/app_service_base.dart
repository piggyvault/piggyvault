import 'package:piggy_flutter/services/rest_client.dart';

abstract class AppServiceBase {
  RestClient rest;

  AppServiceBase() {
    rest = new RestClient();
  }
}
