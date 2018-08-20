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

void main() {
  final CategoryBloc categoryBloc = CategoryBloc();
  final AccountBloc accountBloc = AccountBloc();
  final TransactionBloc transactionBloc = TransactionBloc();
  final UserBloc userBloc = UserBloc();

  runApp(new MyApp(transactionBloc, accountBloc, categoryBloc, userBloc));
}

class MyApp extends StatelessWidget {
  final CategoryBloc categoryBloc;
  final AccountBloc accountBloc;
  final TransactionBloc transactionBloc;
  final UserBloc userBloc;

  MyApp(
      this.transactionBloc, this.accountBloc, this.categoryBloc, this.userBloc);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return UserProvider(
      userBloc: userBloc,
      child: TransactionProvider(
        transactionBloc: transactionBloc,
        child: AccountProvider(
          accountBloc: accountBloc,
          child: CategoryProvider(
            categoryBloc: categoryBloc,
            child: MaterialApp(
              title: 'Piggy',
              theme: new ThemeData(
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
                // counter didn't reset back to zero; the application is not restarted.
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
}
