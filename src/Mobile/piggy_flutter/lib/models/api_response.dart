import 'package:flutter/material.dart';

class ApiResponse<T> {
  final bool success;
  final T result;
  final bool unAuthorizedRequest;
  String error;

  ApiResponse(
      {@required this.success,
      @required this.result,
      @required this.unAuthorizedRequest,
      this.error});
}
