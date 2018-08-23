import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/account_bloc.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/blocs/transaction_bloc.dart';
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
        final AccountBloc accountBloc = BlocProvider.of<AccountBloc>(context);
        final TransactionBloc transactionBloc =
            BlocProvider.of<TransactionBloc>(context);

        switch (p.type) {
          case ApiType.createOrUpdateTransaction:
            {
              accountBloc.accountsRefresh(true);
              transactionBloc.recentTransactionsRefresh(true);
              transactionBloc.transactionSummaryRefresh('month');

              showSuccess(
                  context: context,
                  message: UIData.success,
                  icon: FontAwesomeIcons.check,
                  type: p.type);
            }
            break;
        }
      }
    }
  });
}
