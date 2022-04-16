import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/account/bloc.dart';
import 'package:piggy_flutter/blocs/account_transactions/bloc.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/blocs/transaction_detail/bloc.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/common.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/widgets/add_transaction_fab.dart';
import 'package:piggy_flutter/widgets/common/common.dart';
import 'package:piggy_flutter/widgets/common/search_bar.dart';
import 'package:piggy_flutter/widgets/transaction_list.dart';

import 'account_form.dart';

class AccountDetailPage extends StatefulWidget {
  const AccountDetailPage(
      {Key? key,
      required this.account,
      required this.transactionRepository,
      required this.accountRepository,
      required this.animationController})
      : super(key: key);

  final Account account;
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;
  final AnimationController? animationController;

  @override
  _AccountDetailPageState createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _hideFabAnimation;
  late Animation<double> topBarAnimation;
  late Animation<double> listAnimation;
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  List<Widget> listViews = <Widget>[];
  Completer<void>? _refreshCompleter;

  AccountTransactionsBloc? accountTransactionsBloc;
  AccountBloc? accountBloc;

  DateTime startDate = DateTime.now().add(const Duration(days: -30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    _hideFabAnimation =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);
    _hideFabAnimation.forward();
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController!,
        curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );

    listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: widget.animationController!,
        curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)));

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });

    _refreshCompleter = Completer<void>();

    accountTransactionsBloc = AccountTransactionsBloc(
        transactionRepository: widget.transactionRepository,
        transactionBloc: BlocProvider.of<TransactionBloc>(context));

    accountBloc = AccountBloc(
        accountRepository: widget.accountRepository,
        transactionDetailBloc: BlocProvider.of<TransactionDetailBloc>(context),
        transactionsBloc: BlocProvider.of<TransactionBloc>(context));

    accountBloc!.add(FetchAccount(accountId: widget.account.id!));
    accountTransactionsBloc!.add(
      FetchAccountTransactions(
        input: GetTransactionsInput(
            type: 'account',
            accountId: widget.account.id,
            startDate: startDate,
            endDate: endDate,
            groupBy: TransactionsGroupBy.Date),
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Container(
        color: PiggyAppTheme.background,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: <Widget>[
              getMainListViewUI(),
              getAppBarUI(),
            ],
          ),
          floatingActionButton: widget.account.isArchived
              ? Container()
              : ScaleTransition(
                  scale: _hideFabAnimation,
                  alignment: Alignment.bottomCenter,
                  child: AddTransactionFab(
                    account: widget.account,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideFabAnimation.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            _hideFabAnimation.forward();
            break;
          case ScrollDirection.reverse:
            _hideFabAnimation.reverse();
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          widget.animationController!.forward();
          return AnimatedBuilder(
            animation: widget.animationController!,
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                opacity: listAnimation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 30 * (1.0 - listAnimation.value), 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: AppBar().preferredSize.height +
                            MediaQuery.of(context).padding.top,
                      ),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: NestedScrollView(
                              controller: scrollController,
                              headerSliverBuilder: (BuildContext context,
                                  bool innerBoxIsScrolled) {
                                return <Widget>[
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                      return Column(
                                        children: <Widget>[
                                          SearchBar(
                                            onSearchTextChanged: (txt) {
                                              accountTransactionsBloc!.add(
                                                  FilterAccountTransactions(
                                                      txt));
                                            },
                                          ),
                                          getTimeDateUI(accountTransactionsBloc,
                                              accountBloc),
                                        ],
                                      );
                                    }, childCount: 1),
                                  ),
                                  SliverPersistentHeader(
                                    pinned: true,
                                    floating: true,
                                    delegate: ContestTabHeader(
                                      getFilterBarUI(),
                                    ),
                                  ),
                                ];
                              },
                              body: Container(
                                color: PiggyAppTheme.buildLightTheme()
                                    .backgroundColor,
                                child: BlocBuilder<AccountTransactionsBloc,
                                    AccountTransactionsState>(
                                  bloc: accountTransactionsBloc,
                                  builder: (BuildContext context,
                                      AccountTransactionsState state) {
                                    if (state is AccountTransactionsLoaded) {
                                      _refreshCompleter?.complete();
                                      _refreshCompleter = Completer();
                                    }

                                    if (state is AccountTransactionsEmpty) {
                                      _refreshCompleter?.complete();
                                      _refreshCompleter = Completer();
                                    }

                                    return RefreshIndicator(
                                      onRefresh: () {
                                        accountBloc!.add(FetchAccount(
                                            accountId: widget.account.id!));
                                        accountTransactionsBloc!.add(
                                          FetchAccountTransactions(
                                            input: GetTransactionsInput(
                                                type: 'account',
                                                accountId: widget.account.id,
                                                startDate: startDate,
                                                endDate: endDate,
                                                groupBy:
                                                    TransactionsGroupBy.Date),
                                          ),
                                        );
                                        return _refreshCompleter!.future;
                                      },
                                      child: SafeArea(
                                        top: false,
                                        bottom: false,
                                        child: Column(
                                          children: <Widget>[
                                            Expanded(
                                              child: Stack(
                                                children: <Widget>[
                                                  // Fade in a loading screen when results are being fetched
                                                  LoadingWidget(
                                                      visible: state
                                                          is AccountTransactionsLoading),

                                                  // Fade in an Empty Result screen if the search contained
                                                  // no items
                                                  EmptyResultWidget(
                                                      visible: state
                                                          is AccountTransactionsEmpty),

                                                  // Fade in an error if something went wrong when fetching
                                                  // the results
                                                  ErrorDisplayWidget(
                                                      visible: state
                                                          is AccountTransactionsError),

                                                  // Fade in the Result if available
                                                  TransactionList(
                                                    items: state
                                                            is AccountTransactionsLoaded
                                                        ? state
                                                            .filteredAccountTransactions
                                                            .sections
                                                        : [],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: PiggyAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: PiggyAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AutoSizeText(
                                  widget.account.name!,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: PiggyAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: PiggyAppTheme.darkerText,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                onSelected: (value) {
                                  // print('PopupMenuButton onSelected $value');
                                  switch (value) {
                                    case UIData.account_edit:
                                      {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<
                                              DismissDialogAction>(
                                            builder: (BuildContext context) =>
                                                AccountFormScreen(
                                              account: widget.account,
                                              title: 'Edit Account',
                                            ),
                                            fullscreenDialog: true,
                                          ),
                                        );
                                      }
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: UIData.account_edit,
                                    child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text(UIData.edit),
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: UIData.adjust_balance,
                                    child: ListTile(
                                      leading: Icon(Icons.account_balance),
                                      title: Text(UIData.adjust_balance),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget getTimeDateUI(AccountTransactionsBloc? accountTransactionsBloc,
      AccountBloc? accountBloc) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      showDemoDialog(
                          context: context, bloc: accountTransactionsBloc);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 4, bottom: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Choose date',
                            style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 16,
                                color: Colors.grey.withOpacity(0.8)),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            '${DateFormat("dd, MMM").format(startDate)} - ${DateFormat("dd, MMM").format(endDate)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 1,
              height: 42,
              color: Colors.grey.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 4, bottom: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Current Balance',
                            style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 16,
                                color: Colors.grey.withOpacity(0.8)),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          BlocBuilder<AccountBloc, AccountState>(
                              bloc: accountBloc,
                              builder:
                                  (BuildContext context, AccountState state) {
                                if (state is AccountLoaded) {
                                  return Text(
                                    ' ${state.account.currentBalance} ${state.account.currencySymbol}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w100,
                                      fontSize: 16,
                                    ),
                                  );
                                }
                                if (state is AccountLoading) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SpinKitWave(
                                          size: 16,
                                          color: PiggyAppTheme.buildLightTheme()
                                              .accentColor,
                                          type: SpinKitWaveType.start),
                                      SpinKitWave(
                                          size: 16,
                                          color: PiggyAppTheme.buildLightTheme()
                                              .accentColor,
                                          type: SpinKitWaveType.center),
                                      SpinKitWave(
                                          size: 16,
                                          color: PiggyAppTheme.buildLightTheme()
                                              .accentColor,
                                          type: SpinKitWaveType.end),
                                    ],
                                  );
                                }
                                return const Text(
                                  '---',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w100,
                                    fontSize: 16,
                                  ),
                                );
                              })
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getFilterBarUI() {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: PiggyAppTheme.buildLightTheme().backgroundColor,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(0, -2),
                    blurRadius: 8.0),
              ],
            ),
          ),
        ),
        Container(
          color: PiggyAppTheme.buildLightTheme().backgroundColor,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: BlocBuilder<AccountTransactionsBloc,
                          AccountTransactionsState>(
                      bloc: accountTransactionsBloc,
                      builder: (context, state) {
                        if (state is AccountTransactionsLoaded) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${state.filteredAccountTransactions.transactions.length} transactions found',
                              style: const TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }
                        if (state is AccountTransactionsEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '0 transactions found',
                              style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        if (state is AccountTransactionsLoading) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SpinKitThreeBounce(
                              color:
                                  PiggyAppTheme.buildLightTheme().primaryColor,
                              size: 16,
                            ),
                          );
                        }
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '---',
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    // onTap: () {
                    //   FocusScope.of(context).requestFocus(FocusNode());
                    //   Navigator.push<dynamic>(
                    //     context,
                    //     MaterialPageRoute<dynamic>(
                    //         builder: (BuildContext context) => FiltersScreen(),
                    //         fullscreenDialog: true),
                    //   );
                    // },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: <Widget>[
                          const Text(
                            'Filter',
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 16,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.sort,
                                color: PiggyAppTheme.buildLightTheme()
                                    .primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Divider(
            height: 1,
          ),
        )
      ],
    );
  }

  void showDemoDialog(
      {required BuildContext context, AccountTransactionsBloc? bloc}) {
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) => CalendarPopupView(
        barrierDismissible: true,
        // minimumDate: DateTime.now(),
        //  maximumDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 10),
        initialEndDate: endDate,
        initialStartDate: startDate,
        onApplyClick: (DateTime startData, DateTime endData) {
          setState(() {
            if (startData != null && endData != null) {
              startDate = startData;
              endDate = endData;
            }
          });
          bloc!.add(FetchAccountTransactions(
              input: GetTransactionsInput(
                  type: 'account',
                  accountId: widget.account.id,
                  startDate: startDate,
                  endDate: endDate,
                  groupBy: TransactionsGroupBy.Date)));
        },
        onCancelClick: () {},
      ),
    );
  }
}
