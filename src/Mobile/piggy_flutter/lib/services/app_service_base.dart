import 'package:piggy_flutter/utils/rest_client.dart';

abstract class AppServiceBase {
  late RestClient rest;

  AppServiceBase() {
    rest = new RestClient();
  }
}
