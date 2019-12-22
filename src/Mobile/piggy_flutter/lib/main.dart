import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts_bloc.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/blocs/categories/categories_bloc.dart';
import 'package:piggy_flutter/blocs/recent_transactions/recent_transactions_bloc.dart';
import 'package:piggy_flutter/blocs/transaction/transaction_bloc.dart';
import 'package:piggy_flutter/blocs/transaction_detail/bloc.dart';
import 'package:piggy_flutter/blocs/transaction_summary/transaction_summary_bloc.dart';
import 'package:piggy_flutter/dashboard/dashboard_bloc.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/screens/home/home_screen.dart';
import 'package:piggy_flutter/screens/intro_views/intro_views.dart';
import 'package:piggy_flutter/splash/splash.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:http/http.dart' as http;

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

  final AccountRepository accountRepository =
      AccountRepository(piggyApiClient: piggyApiClient);

  final CategoryRepository categoryRepository =
      CategoryRepository(piggyApiClient: piggyApiClient);

  final ReportRepository reportRepository =
      ReportRepository(piggyApiClient: piggyApiClient);

  BlocSupervisor.delegate = PiggyBlocDelegate();
  // debugPrintRebuildDirtyWidgets = true;
  return runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(
        builder: (BuildContext context) =>
            AuthBloc(userRepository: userRepository)..add(AppStarted()),
      ),
      BlocProvider<TransactionBloc>(
        builder: (BuildContext context) =>
            TransactionBloc(transactionRepository: transactionRepository),
      ),
      BlocProvider<TransactionDetailBloc>(
        builder: (BuildContext context) =>
            TransactionDetailBloc(transactionRepository: transactionRepository),
      ),
      BlocProvider<CategoriesBloc>(
          builder: (BuildContext context) => CategoriesBloc(
              categoryRepository: categoryRepository,
              authBloc: BlocProvider.of<AuthBloc>(context))),
      BlocProvider<AccountsBloc>(
          builder: (BuildContext context) => AccountsBloc(
              accountRepository: accountRepository,
              transactionsBloc: BlocProvider.of<TransactionBloc>(context),
              transactionDetailBloc:
                  BlocProvider.of<TransactionDetailBloc>(context),
              authBloc: BlocProvider.of<AuthBloc>(context))),
      BlocProvider<RecentTransactionsBloc>(
        builder: (BuildContext context) => RecentTransactionsBloc(
            transactionDetailBloc:
                BlocProvider.of<TransactionDetailBloc>(context),
            transactionRepository: transactionRepository,
            transactionsBloc: BlocProvider.of<TransactionBloc>(context),
            authBloc: BlocProvider.of<AuthBloc>(context)),
      ),
      BlocProvider<TransactionSummaryBloc>(
        builder: (BuildContext context) => TransactionSummaryBloc(
            transactionDetailBloc:
                BlocProvider.of<TransactionDetailBloc>(context),
            transactionsBloc: BlocProvider.of<TransactionBloc>(context),
            authBloc: BlocProvider.of<AuthBloc>(context),
            transactionRepository: transactionRepository),
      ),
      BlocProvider<DashboardBloc>(
          builder: (BuildContext context) =>
              DashboardBloc()), // TODO(abhith): remove if not needed
    ],
    child: App(
      transactionRepository: transactionRepository,
      userRepository: userRepository,
      accountRepository: accountRepository,
      reportRepository: reportRepository,
    ),
  ));
}

class App extends StatelessWidget {
  const App({
    Key key,
    @required this.userRepository,
    @required this.transactionRepository,
    @required this.accountRepository,
    @required this.reportRepository,
  }) : super(key: key);

  final UserRepository userRepository;
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;
  final ReportRepository reportRepository;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TransactionRepository>(
          builder: (BuildContext context) => transactionRepository,
        ),
        RepositoryProvider<AccountRepository>(
          builder: (BuildContext context) => accountRepository,
        ),
        RepositoryProvider<UserRepository>(
          builder: (BuildContext context) => userRepository,
        ),
        RepositoryProvider<ReportRepository>(
          builder: (BuildContext context) => reportRepository,
        )
      ],
      child: MaterialApp(
        title: 'Piggy',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: PiggyAppTheme.textTheme,
            platform: TargetPlatform.iOS,
            primaryColor: Colors.white),
        home: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          if (state is AuthAuthenticated) {
            return const HomeScreen();
          }
          if (state is AuthUnauthenticated) {
            return LoginPage(userRepository: userRepository);
          }
          if (state is FirstAccess) {
            return IntroViews();
          }
          return SplashPage();
        }),
        routes: <String, WidgetBuilder>{
          UIData.loginRoute: (BuildContext context) => LoginPage(
                userRepository: userRepository,
              ),
          UIData.dashboardRoute: (BuildContext context) => HomeScreen(),
        },
      ),
    );
  }
}
