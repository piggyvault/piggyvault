import 'package:flutter/material.dart';

class AjaxResponse<T> {
  final bool success;
  final T result;
  final bool unAuthorizedRequest;
  String error;

  AjaxResponse(
      {@required this.success,
      @required this.result,
      @required this.unAuthorizedRequest,
      this.error});
}
