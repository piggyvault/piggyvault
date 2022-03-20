import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:piggy_flutter/blocs/accounts/accounts_bloc.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/blocs/categories/categories_bloc.dart';
import 'package:piggy_flutter/blocs/recent_transactions/recent_transactions_bloc.dart';
import 'package:piggy_flutter/blocs/transaction/transaction_bloc.dart';
import 'package:piggy_flutter/blocs/transaction_detail/bloc.dart';
import 'package:piggy_flutter/blocs/transaction_summary/transaction_summary_bloc.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/screens/home/home_screen.dart';
import 'package:piggy_flutter/screens/intro_views/intro_views.dart';
import 'package:piggy_flutter/splash/splash.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'login/login.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureLocalTimeZone();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();
  const MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  });

  await _cancelAllNotifications();
  await _scheduleReminderNotification();

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

  // debugPrintRebuildDirtyWidgets = true;
  return runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(
        lazy: false,
        create: (BuildContext context) =>
            AuthBloc(userRepository: userRepository)..add(AppStarted()),
      ),
      BlocProvider<TransactionBloc>(
        lazy: false,
        create: (BuildContext context) =>
            TransactionBloc(transactionRepository: transactionRepository),
      ),
      BlocProvider<TransactionDetailBloc>(
        lazy: false,
        create: (BuildContext context) =>
            TransactionDetailBloc(transactionRepository: transactionRepository),
      ),
      BlocProvider<CategoriesBloc>(
          lazy: false,
          create: (BuildContext context) => CategoriesBloc(
              categoryRepository: categoryRepository,
              authBloc: BlocProvider.of<AuthBloc>(context))),
      BlocProvider<AccountsBloc>(
          lazy: false,
          create: (BuildContext context) => AccountsBloc(
              accountRepository: accountRepository,
              transactionsBloc: BlocProvider.of<TransactionBloc>(context),
              transactionDetailBloc:
                  BlocProvider.of<TransactionDetailBloc>(context),
              authBloc: BlocProvider.of<AuthBloc>(context))),
      BlocProvider<RecentTransactionsBloc>(
        lazy: false,
        create: (BuildContext context) => RecentTransactionsBloc(
            transactionDetailBloc:
                BlocProvider.of<TransactionDetailBloc>(context),
            transactionRepository: transactionRepository,
            transactionsBloc: BlocProvider.of<TransactionBloc>(context),
            authBloc: BlocProvider.of<AuthBloc>(context)),
      ),
      BlocProvider<TransactionSummaryBloc>(
        lazy: false,
        create: (BuildContext context) => TransactionSummaryBloc(
            transactionDetailBloc:
                BlocProvider.of<TransactionDetailBloc>(context),
            transactionsBloc: BlocProvider.of<TransactionBloc>(context),
            authBloc: BlocProvider.of<AuthBloc>(context),
            transactionRepository: transactionRepository),
      )
    ],
    child: App(
      transactionRepository: transactionRepository,
      userRepository: userRepository,
      accountRepository: accountRepository,
      reportRepository: reportRepository,
    ),
  ));
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

Future<void> _cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> _scheduleReminderNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Forget something to add?',
      "Looks like it's been awhile...",
      tz.TZDateTime.now(tz.local).add(const Duration(days: 1)),
      const NotificationDetails(
          android: AndroidNotificationDetails('Reminder', 'Reminder',
              channelDescription: 'To remind you about saving transactions')),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);
}

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.userRepository,
    required this.transactionRepository,
    required this.accountRepository,
    required this.reportRepository,
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
          create: (BuildContext context) => transactionRepository,
        ),
        RepositoryProvider<AccountRepository>(
          create: (BuildContext context) => accountRepository,
        ),
        RepositoryProvider<UserRepository>(
          create: (BuildContext context) => userRepository,
        ),
        RepositoryProvider<ReportRepository>(
          create: (BuildContext context) => reportRepository,
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
          UIData.dashboardRoute: (BuildContext context) => const HomeScreen(),
        },
      ),
    );
  }
}
