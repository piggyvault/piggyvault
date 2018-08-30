import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/account_bloc.dart';
import 'package:piggy_flutter/blocs/application_bloc.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/blocs/category_bloc.dart';
import 'package:piggy_flutter/blocs/transaction_bloc.dart';
import 'package:piggy_flutter/blocs/user_bloc.dart';
import 'package:piggy_flutter/screens/category/category_list.dart';
import 'package:piggy_flutter/screens/home/home.dart';
import 'package:piggy_flutter/screens/login/login_page.dart';
import 'package:piggy_flutter/screens/reports/categorywise_recent_months_report_screen.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:onesignal/onesignal.dart';

Future<void> main() async {
  // debugPrintRebuildDirtyWidgets = true;
  return runApp(
    BlocProvider<ApplicationBloc>(
      bloc: ApplicationBloc(),
      child: BlocProvider<UserBloc>(
        bloc: UserBloc(),
        child: BlocProvider<TransactionBloc>(
          bloc: TransactionBloc(),
          child: BlocProvider<AccountBloc>(
            bloc: AccountBloc(),
            child: BlocProvider<CategoryBloc>(
              bloc: CategoryBloc(),
              child: MyApp(),
            ),
          ),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
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
    return MaterialApp(
      title: 'Piggy',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: <String, WidgetBuilder>{
        UIData.loginRoute: (BuildContext context) => LoginPage(),
        UIData.dashboardRoute: (BuildContext context) => HomePage(),
        UIData.categoriesRoute: (BuildContext context) => CategoryListPage(),
        CategoryWiseRecentMonthsReportScreen.routeName:
            (BuildContext context) => CategoryWiseRecentMonthsReportScreen(),
      },
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
