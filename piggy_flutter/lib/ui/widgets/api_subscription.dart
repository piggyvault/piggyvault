import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/models/api_request.dart';
import 'package:piggy_flutter/ui/widgets/common/common_dialogs.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

apiSubscription(Stream<ApiRequest> apiResult, BuildContext context) {
  apiResult.listen((ApiRequest p) {
    if (p.isInProcess) {
      showProgress(context);
    } else {
      hideProgress(context);
      if (p.response.success == false) {
        showError(context, p.response);
      } else {
        switch (p.type) {
          case ApiType.createOrUpdateTransaction:
            showSuccess(
                context: context,
                message: UIData.success,
                icon: FontAwesomeIcons.check,
                type: p.type);
            break;
        }
      }
    }
  });
}
