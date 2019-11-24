import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts.dart';
import 'package:piggy_flutter/blocs/categories/categories.dart';
import 'package:piggy_flutter/models/api_request.dart';
import 'package:piggy_flutter/widgets/common/common_dialogs.dart';
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
        // final HomeBloc homeBloc =
        //     oldProvider.BlocProvider.of<HomeBloc>(context);
        final AccountsBloc accountsBloc =
            BlocProvider.of<AccountsBloc>(context);

        switch (p.type) {
          case ApiType.login:
            {
              if (p.response.result == null) {
                showErrorMessage(
                    key: key,
                    errorMessage:
                        'Something went wrong, check the credentials and try again.');
              } else {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => HomePage(
                //       isInitialLoading: true,
                //     ),
                //   ),
                // );
              }
            }
            break;
          case ApiType.createOrUpdateTransaction:
          case ApiType.deleteTransaction:
          case ApiType.updateAccount:
            {
              accountsBloc.add(LoadAccounts());
              // homeBloc.syncData(true);
              showSuccess(
                  context: context,
                  message: UIData.success,
                  icon: FontAwesomeIcons.check);
            }
            break;
          case ApiType.createCategory:
          case ApiType.updateCategory:
            {
              final CategoriesBloc categoriesBloc =
                  BlocProvider.of<CategoriesBloc>(context);
              categoriesBloc.add(LoadCategories());

              if (p.type == ApiType.updateCategory) {
                // homeBloc.syncData(true);
              }
              showSuccess(
                  context: context,
                  message: UIData.category_update_success_message,
                  icon: FontAwesomeIcons.check);
            }
            break;
          case ApiType.createAccount:
            {
              accountsBloc.add(LoadAccounts());
              showSuccess(
                  context: context,
                  message: UIData.success,
                  icon: FontAwesomeIcons.check);
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

void showSuccessMessage(
    {@required GlobalKey<ScaffoldState> key, @required String message}) {
  showMessage(key: key, color: Colors.greenAccent, message: message);
}

void showErrorMessage(
    {@required GlobalKey<ScaffoldState> key, @required String errorMessage}) {
  showMessage(key: key, color: Colors.red, message: errorMessage);
}
