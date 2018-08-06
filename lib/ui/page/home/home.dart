import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/account_bloc.dart';
import 'package:piggy_flutter/bloc/transaction_bloc.dart';
import 'package:piggy_flutter/bloc/user_bloc.dart';
import 'package:piggy_flutter/providers/account_provider.dart';
import 'package:piggy_flutter/providers/transaction_provider.dart';
import 'package:piggy_flutter/providers/user_provider.dart';
import 'package:piggy_flutter/ui/page/account/account_list.dart';
import 'package:piggy_flutter/ui/page/home/recent.dart';
import 'package:piggy_flutter/ui/page/home/summary.dart';
import 'package:piggy_flutter/ui/widgets/common/common_drawer.dart';

class NavigationIconView {
  NavigationIconView({
    Widget icon,
    Widget activeIcon,
    String title,
    Color color,
    TickerProvider vsync,
  })  : _icon = icon,
        _color = color,
        _title = title,
        item = new BottomNavigationBarItem(
          icon: icon,
//          activeIcon: activeIcon,
          title: new Text(title),
          backgroundColor: color,
        ),
        controller = new AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vsync,
        ) {
    _animation = new CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
  }

  final Widget _icon;
  final Color _color;
  final String _title;
  final BottomNavigationBarItem item;
  final AnimationController controller;
  CurvedAnimation _animation;

  FadeTransition transition(
      BottomNavigationBarType type, BuildContext context) {
    Color iconColor;
    if (type == BottomNavigationBarType.shifting) {
      iconColor = _color;
    } else {
      final ThemeData themeData = Theme.of(context);
      iconColor = themeData.brightness == Brightness.light
          ? themeData.primaryColor
          : themeData.accentColor;
    }

    return new FadeTransition(
      opacity: _animation,
      child: new SlideTransition(
        position: new Tween<Offset>(
          begin: const Offset(0.0, 0.02), // Slightly down.
          end: Offset.zero,
        ).animate(_animation),
        child: new IconTheme(
          data: new IconThemeData(
            color: iconColor,
            size: 120.0,
          ),
          child: new Semantics(
            label: 'Placeholder for $_title tab',
            child: _icon,
          ),
        ),
      ),
    );
  }
}

enum StartPage { Recent, Accounts, Summary }

class HomePage extends StatefulWidget {
  final bool isInitialLoading;
  final StartPage startpage;

  HomePage(
      {Key key,
      this.isInitialLoading = false,
      this.startpage = StartPage.Recent})
      : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  List<NavigationIconView> _navigationViews;

  final Key keyRecentPage = PageStorageKey('recent');
  final Key keyAccountsPage = PageStorageKey('accounts');
  final Key keySummaryPage = PageStorageKey('summary');

  RecentPage recent;
  SummaryPage summary;
  AccountListPage accounts;

  List<Widget> pages;
  bool isSyncRequired;

  /// This controller can be used to programmatically
  /// set the current displayed page
  PageController _pageController;

  @override
  void initState() {
    _navigationViews = <NavigationIconView>[
      new NavigationIconView(
        icon: const Icon(Icons.format_list_bulleted),
        title: 'Recent',
        color: Colors.deepPurple,
        vsync: this,
      ),
      new NavigationIconView(
        activeIcon: const Icon(Icons.account_box),
        icon: const Icon(Icons.account_circle),
        title: 'Accounts',
        color: Colors.teal,
        vsync: this,
      ),
      new NavigationIconView(
        activeIcon: const Icon(Icons.dashboard),
        icon: const Icon(Icons.dashboard),
        title: 'Dashboard',
        color: Colors.indigo,
        vsync: this,
      ),
    ];

    for (NavigationIconView view in _navigationViews)
      view.controller.addListener(_rebuild);

    summary = new SummaryPage(key: keySummaryPage);
    recent = new RecentPage(
      key: keyRecentPage,
    );
    accounts = new AccountListPage(
      key: keyAccountsPage,
    );

    _pageController = new PageController(initialPage: widget.startpage.index);

    pages = [recent, accounts, summary];
    isSyncRequired = widget.isInitialLoading;
    _currentIndex = widget.startpage.index;
    _navigationViews[_currentIndex].controller.value = 1.0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = UserProvider.of(context);
    final TransactionBloc transactionBloc = TransactionProvider.of(context);
    final AccountBloc accountBloc = AccountProvider.of(context);
    if (isSyncRequired) {
      userBloc.userRefresh(true);
      transactionBloc.recentTransactionsRefresh(true);
      transactionBloc.transactionSummaryRefresh('month');
      accountBloc.accountsRefresh(true);
      isSyncRequired = false;
    }

    return new Scaffold(
      body: new PageView(
          children: pages,
          controller: _pageController,
          onPageChanged: onPageChanged),
      bottomNavigationBar: new BottomNavigationBar(
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
