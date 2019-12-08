import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts_bloc.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/blocs/categories/categories_bloc.dart';
import 'package:piggy_flutter/blocs/recent_transactions/recent_transactions_bloc.dart';
import 'package:piggy_flutter/blocs/transaction/transaction_bloc.dart';
import 'package:piggy_flutter/blocs/transaction_summary/transaction_summary_bloc.dart';
import 'package:piggy_flutter/dashboard/dashboard_bloc.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/screens/home/home_screen.dart';
import 'package:piggy_flutter/screens/intro_views/intro_views.dart';
import 'package:piggy_flutter/splash/splash.dart';
import 'package:piggy_flutter/themes.dart';
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

  BlocSupervisor.delegate = PiggyBlocDelegate();
  // debugPrintRebuildDirtyWidgets = true;
  return runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(
        builder: (context) =>
            AuthBloc(userRepository: userRepository)..add(AppStarted()),
      ),
      BlocProvider<TransactionBloc>(
        builder: (context) =>
            TransactionBloc(transactionRepository: transactionRepository),
      ),
      BlocProvider<CategoriesBloc>(
          builder: (context) => CategoriesBloc(
              categoryRepository: categoryRepository,
              authBloc: BlocProvider.of<AuthBloc>(context))),
      BlocProvider<AccountsBloc>(
          builder: (context) => AccountsBloc(
              accountRepository: accountRepository,
              transactionsBloc: BlocProvider.of<TransactionBloc>(context),
              authBloc: BlocProvider.of<AuthBloc>(context))),
      BlocProvider<RecentTransactionsBloc>(
        builder: (context) => RecentTransactionsBloc(
            transactionRepository: transactionRepository,
            transactionsBloc: BlocProvider.of<TransactionBloc>(context),
            authBloc: BlocProvider.of<AuthBloc>(context)),
      ),
      BlocProvider<TransactionSummaryBloc>(
        builder: (context) => TransactionSummaryBloc(
            transactionsBloc: BlocProvider.of<TransactionBloc>(context),
            authBloc: BlocProvider.of<AuthBloc>(context),
            transactionRepository: transactionRepository),
      ),
      BlocProvider<DashboardBloc>(
          builder: (context) => DashboardBloc()), // TODO: remove if not needed
    ],
    child: App(
      transactionRepository: transactionRepository,
      userRepository: userRepository,
      accountRepository: accountRepository,
    ),
  ));
}

class App extends StatelessWidget {
  final UserRepository userRepository;
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;

  App({
    Key key,
    @required this.userRepository,
    @required this.transactionRepository,
    @required this.accountRepository,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TransactionRepository>(
          builder: (context) => transactionRepository,
        ),
        RepositoryProvider<AccountRepository>(
          builder: (context) => accountRepository,
        ),
        RepositoryProvider<UserRepository>(
          builder: (context) => userRepository,
        ),
      ],
      child: MaterialApp(
        title: 'Piggy',
        theme: lightAppTheme.data,
        home: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          if (state is AuthAuthenticated) {
            return HomeScreen();
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
