import 'package:piggy_flutter/services/network_service_response.dart';

enum ApiType { createOrUpdateTransaction }

class ApiRequest<T> {
  ApiType type;
  bool isInProcess;
  NetworkServiceResponse<T> response;

  ApiRequest({this.isInProcess, this.response, this.type});

  @override
  String toString() {
    // TODO: implement toString
    return 'ApiRequest isInProcess $isInProcess, type $type';
  }
}
