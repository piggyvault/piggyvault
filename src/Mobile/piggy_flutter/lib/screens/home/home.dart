import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:piggy_flutter/blocs/account_bloc.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart' as oldProvider;
import 'package:piggy_flutter/blocs/category_bloc.dart';
import 'package:piggy_flutter/dashboard/index.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/screens/account/account_list.dart';
import 'package:piggy_flutter/screens/home/home_bloc.dart';
import 'package:piggy_flutter/screens/home/recent.dart';
import 'package:piggy_flutter/screens/home/summary.dart';
import 'package:piggy_flutter/screens/transaction/transaction_detail.dart';
import 'package:piggy_flutter/widgets/common/common_drawer.dart';
import 'package:connectivity/connectivity.dart';

class NavigationIconView {
  NavigationIconView({
    Widget icon,
    Widget activeIcon,
    String title,
    Color color,
    TickerProvider vsync,
  })  : item = new BottomNavigationBarItem(
          icon: icon,
          title: new Text(title),
          backgroundColor: color,
        ),
        controller = new AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vsync,
        );

  final BottomNavigationBarItem item;
  final AnimationController controller;
}

enum StartPage { Dashboard, Recent, Accounts, Summary }

class HomePage extends StatefulWidget {
  final bool isInitialLoading;
  final StartPage startpage;

  HomePage(
      {Key key,
      this.isInitialLoading = false,
      this.startpage = StartPage.Dashboard})
      : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  List<NavigationIconView> _navigationViews;

  final Key _keyRecentPage = PageStorageKey('recent');
  final Key _keyAccountsPage = PageStorageKey('accounts');
  final Key _keySummaryPage = PageStorageKey('summary');
  final Key _dashboardKey = PageStorageKey('dashboard');

  RecentPage _recent;
  SummaryPage _summary;
  AccountListPage _accounts;
  DashboardPage _dashboardScreen;

  List<Widget> _pages;
  bool _isSyncRequired;

  PageController _pageController;
  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _navigationViews = <NavigationIconView>[
      new NavigationIconView(
        icon: const Icon(Icons.dashboard),
        title: 'Dashboard',
        color: Colors.lightBlue,
        vsync: this,
      ),
      new NavigationIconView(
        icon: const Icon(Icons.format_list_bulleted),
        title: 'Recent',
        color: Colors.deepPurple,
        vsync: this,
      ),
      new NavigationIconView(
        icon: const Icon(Icons.account_circle),
        title: 'Accounts',
        color: Colors.teal,
        vsync: this,
      ),
      new NavigationIconView(
        icon: const Icon(Icons.work),
        title: 'Summary',
        color: Colors.indigo,
        vsync: this,
      ),
    ];

    for (NavigationIconView view in _navigationViews)
      view.controller.addListener(_rebuild);

    _summary = SummaryPage(key: _keySummaryPage);
    _recent = RecentPage(
      key: _keyRecentPage,
    );
    _accounts = AccountListPage(
      key: _keyAccountsPage,
    );

    _dashboardScreen = DashboardPage();

    _pageController = PageController(initialPage: widget.startpage.index);

    _pages = [_dashboardScreen, _recent, _accounts, _summary];
    _isSyncRequired = widget.isInitialLoading ?? false;
    _currentIndex = widget.startpage.index;
    _navigationViews[_currentIndex].controller.value = 1.0;

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _isSyncRequired = true;
      } else {
        syncData(context);
      }
    });

    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // print(
      //     "########## Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}");
      var transactionData = result.notification.payload.additionalData;
      try {
        var transaction = Transaction(
            id: transactionData['TransactionId'],
            transactionTime: transactionData['TransactionTime'],
            description: transactionData['Description'],
            amount: double.tryParse(transactionData['Amount']),
            categoryName: transactionData['CategoryName'],
            creatorUserName: transactionData['CreatorUserName'],
            accountName: transactionData['AccountName']);
        // TODO: get data from Id rather than sending over notification
        // print(
        //     "########## Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}");
        Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (BuildContext context) => TransactionDetailPage(
                transaction: transaction,
              ),
              fullscreenDialog: true,
            ));
      } catch (e) {
        print(e);
      }
    });
  }

  syncData(BuildContext context) {
    if (_isSyncRequired) {
      final AccountBloc accountBloc =
          oldProvider.BlocProvider.of<AccountBloc>(context);
      final CategoryBloc categoryBloc =
          oldProvider.BlocProvider.of<CategoryBloc>(context);
      final HomeBloc homeBloc = oldProvider.BlocProvider.of<HomeBloc>(context);

      // print('##### syncing data');
      _isSyncRequired = false;
      homeBloc.syncData(true);
      accountBloc.accountsRefresh(true);
      categoryBloc.refreshCategories(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    syncData(context);

    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
          children: _pages,
          controller: _pageController,
          onPageChanged: onPageChanged),
      bottomNavigationBar: BottomNavigationBar(
        items: _navigationViews
            .map((NavigationIconView navigationView) => navigationView.item)
            .toList(),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.shifting,
        onTap: navigationTapped,
      ),
      drawer: CommonDrawer(),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    for (NavigationIconView view in _navigationViews) view.controller.dispose();
    super.dispose();
    _pageController.dispose();
  }

  void _rebuild() {
    setState(() {
      // Rebuild in order to animate views.
    });
  }

  /// Called when the user presses on of the
  /// [BottomNavigationBarItem] with corresponding
  /// page index
  void navigationTapped(int page) {
    // Animating to the page.
    // You can use whatever duration and curve you like
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void onPageChanged(int page) {
    setState(() {
      this._currentIndex = page;
    });
  }
}
