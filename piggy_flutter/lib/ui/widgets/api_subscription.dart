import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/account_bloc.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/blocs/category_bloc.dart';
import 'package:piggy_flutter/blocs/transaction_bloc.dart';
import 'package:piggy_flutter/models/api_request.dart';
import 'package:piggy_flutter/ui/screens/home/home.dart';
import 'package:piggy_flutter/ui/widgets/common/common_dialogs.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

apiSubscription(
    {@required Stream<ApiRequest> stream,
    @required BuildContext context,
    @required GlobalKey<ScaffoldState> key}) {
  stream.listen((ApiRequest p) {
    print(p);
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
          case ApiType.login:
            {
              if (p.response.content == null) {
                showErrorMessage(
                    key: key,
                    errorMessage:
                        'Something went wrong, check the credentials and try again.');
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                          isInitialLoading: true,
                        ),
                  ),
                );
              }
            }
            break;
          case ApiType.createOrUpdateTransaction:
          case ApiType.deleteTransaction:
            {
              accountBloc.accountsRefresh(true);
              transactionBloc.sync(true);
              showSuccess(
                  context: context,
                  message: UIData.success,
                  icon: FontAwesomeIcons.check,
                  type: p.type);
            }
            break;
          case ApiType.createCategory:
          case ApiType.updateCategory:
            {
              final CategoryBloc categoryBloc =
                  BlocProvider.of<CategoryBloc>(context);
              categoryBloc.refreshCategories(true);

              if (p.type == ApiType.updateCategory) {
                transactionBloc.sync(true);
              }

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

void showMessage(
    {@required GlobalKey<ScaffoldState> key,
    @required Color color,
    @required String message}) {
  key?.currentState?.showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(message),
    ),
  );
}

void showErrorMessage(
    {@required GlobalKey<ScaffoldState> key, @required String errorMessage}) {
  showMessage(key: key, color: Colors.red, message: errorMessage);
}
