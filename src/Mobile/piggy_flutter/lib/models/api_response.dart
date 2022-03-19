import 'package:flutter/material.dart';

class ApiResponse<T> {
  ApiResponse(
      {required this.success,
      required this.result,
      required this.unAuthorizedRequest,
      this.error});

  final bool? success;
  final T result;
  final bool? unAuthorizedRequest;
  String? error;
}
