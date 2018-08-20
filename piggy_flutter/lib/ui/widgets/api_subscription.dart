import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/model/api_request.dart';
import 'package:piggy_flutter/ui/widgets/common/common_dialogs.dart';
// import 'package:piggy_flutter/utils/uidata.dart';

apiSubscription(Stream<ApiRequest> apiResult, BuildContext context) {
  apiResult.listen((ApiRequest p) {
    if (p.isInProcess) {
      showProgress(context);
    } else {
      hideProgress(context);
      // if (p.response.success == false) {
      //   fetchApiResult(context, p.response);
      // } else {
      //   switch (p.type) {
      //     case ApiType.createOrUpdateTransaction:
      //       showSuccess(context, UIData.success, Icons.assignment_turned_in);
      //       break;
      //   }
      // }
    }
  });
}
