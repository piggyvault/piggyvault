import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/account_bloc.dart';
import 'package:piggy_flutter/bloc/category_bloc.dart';
import 'package:piggy_flutter/bloc/transaction_bloc.dart';
import 'package:piggy_flutter/bloc/user_bloc.dart';
import 'package:piggy_flutter/providers/account_provider.dart';
import 'package:piggy_flutter/providers/category_provider.dart';
import 'package:piggy_flutter/providers/transaction_provider.dart';
import 'package:piggy_flutter/providers/user_provider.dart';
import 'package:piggy_flutter/ui/page/category/category_list.dart';
import 'package:piggy_flutter/ui/page/login/login_page.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/ui/page/home/home.dart';
import 'package:onesignal/onesignal.dart';

void main() {
  final CategoryBloc categoryBloc = CategoryBloc();
  final AccountBloc accountBloc = AccountBloc();
  final TransactionBloc transactionBloc = TransactionBloc();
  final UserBloc userBloc = UserBloc();

  runApp(new MyApp(transactionBloc, accountBloc, categoryBloc, userBloc));
}

class MyApp extends StatefulWidget {
  final CategoryBloc categoryBloc;
  final AccountBloc accountBloc;
  final TransactionBloc transactionBloc;
  final UserBloc userBloc;

  MyApp(
      this.transactionBloc, this.accountBloc, this.categoryBloc, this.userBloc);

  // This widget is the root of your application.
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return UserProvider(
      userBloc: widget.userBloc,
      child: TransactionProvider(
        transactionBloc: widget.transactionBloc,
        child: AccountProvider(
          accountBloc: widget.accountBloc,
          child: CategoryProvider(
            categoryBloc: widget.categoryBloc,
            child: MaterialApp(
              title: 'Piggy',
              theme: new ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: new LoginPage(),
              routes: <String, WidgetBuilder>{
                UIData.loginRoute: (BuildContext context) => LoginPage(),
                UIData.dashboardRoute: (BuildContext context) => HomePage(),
                UIData.categoryRoute: (BuildContext context) =>
                    CategoryListPage(),
              },
            ),
          ),
        ),
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.warn, OSLogLevel.none);

    // OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.setNotificationReceivedHandler((notification) {
      // print(
      //     "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}");
    });

    // The App ID should not be treated as private.
    await OneSignal.shared
        .init("9bf198c9-442b-4619-b5c9-759fc250f15b", iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    // bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();
  }
}
