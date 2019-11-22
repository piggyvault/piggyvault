import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/account_bloc.dart';
import 'package:piggy_flutter/blocs/application_bloc.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart' as oldProvider;
import 'package:piggy_flutter/blocs/category_bloc.dart';
import 'package:piggy_flutter/blocs/transaction_summary/transaction_summary_bloc.dart';
import 'package:piggy_flutter/dashboard/dashboard_bloc.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/screens/category/category_list.dart';
import 'package:piggy_flutter/screens/home/home.dart';
import 'package:piggy_flutter/screens/home/home_bloc.dart';
import 'package:piggy_flutter/screens/reports/categorywise_recent_months_report_screen.dart';
import 'package:piggy_flutter/splash/splash.dart';
import 'package:piggy_flutter/themes.dart';
import 'package:piggy_flutter/user/user_bloc.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:http/http.dart' as http;

import 'auth/auth.dart';
import 'login/login.dart';

class PiggyBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

Future<void> main() async {
  final PiggyApiClient piggyApiClient = PiggyApiClient(
    httpClient: http.Client(),
  );
  final UserRepository userRepository =
      UserRepository(piggyApiClient: piggyApiClient);

  final TransactionRepository transactionRepository =
      TransactionRepository(piggyApiClient: piggyApiClient);

  BlocSupervisor.delegate = PiggyBlocDelegate();
  // debugPrintRebuildDirtyWidgets = true;
  return runApp(MultiBlocProvider(
    providers: [
      BlocProvider<UserBloc>(builder: (context) => UserBloc()),
      BlocProvider<TransactionSummaryBloc>(
        builder: (context) => TransactionSummaryBloc(
            transactionRepository: transactionRepository),
      ),
      BlocProvider<AuthBloc>(
        builder: (context) => AuthBloc(
            userRepository: userRepository,
            userBloc: BlocProvider.of<UserBloc>(context),
            transactionSummaryBloc:
                BlocProvider.of<TransactionSummaryBloc>(context))
          ..add(AppStarted()),
      ),
      BlocProvider<DashboardBloc>(builder: (context) => DashboardBloc())
    ],
    child: oldProvider.BlocProvider<ApplicationBloc>(
      bloc: ApplicationBloc(),
      child: oldProvider.BlocProvider<HomeBloc>(
        bloc: HomeBloc(),
        child: oldProvider.BlocProvider<AccountBloc>(
          bloc: AccountBloc(),
          child: oldProvider.BlocProvider<CategoryBloc>(
            bloc: CategoryBloc(),
            child: App(userRepository: userRepository),
          ),
        ),
      ),
    ),
  ));
}

class App extends StatelessWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piggy',
      theme: lightAppTheme.data,
      home: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        if (state is AuthAuthenticated) {
          return HomePage();
        }
        if (state is AuthUnauthenticated) {
          return LoginPage(userRepository: userRepository);
        }
        return SplashPage();
      }),
      routes: <String, WidgetBuilder>{
        UIData.loginRoute: (BuildContext context) => LoginPage(
              userRepository: userRepository,
            ),
        UIData.dashboardRoute: (BuildContext context) => HomePage(),
        UIData.categoriesRoute: (BuildContext context) => CategoryListPage(),
        CategoryWiseRecentMonthsReportScreen.routeName:
            (BuildContext context) => CategoryWiseRecentMonthsReportScreen(),
      },
    );
  }
}
