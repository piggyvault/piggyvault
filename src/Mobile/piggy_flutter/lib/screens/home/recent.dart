import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/recent_transactions/bloc.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/models/transaction_group_item.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/widgets/add_transaction_fab.dart';
import 'package:piggy_flutter/widgets/common/calendar_popup_view.dart';
import 'package:piggy_flutter/widgets/common/empty_result_widget.dart';
import 'package:piggy_flutter/widgets/common/error_display_widget.dart';
import 'package:piggy_flutter/widgets/common/loading_widget.dart';
import 'package:piggy_flutter/widgets/transaction_list.dart';

class RecentPage extends StatefulWidget {
  RecentPage({Key key}) : super(key: key);

  @override
  _RecentPageState createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> with TickerProviderStateMixin {
  AnimationController animationController;
  final ScrollController _scrollController = ScrollController();

  Completer<void> _refreshCompleter;
  RecentTransactionsBloc recentTransactionsBloc;

  DateTime startDate = DateTime.now().add(const Duration(days: -30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    recentTransactionsBloc = BlocProvider.of<RecentTransactionsBloc>(context);
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _refreshCompleter = Completer<void>();
    super.initState();
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: PiggyAppTheme.buildLightTheme(),
      child: Container(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  children: <Widget>[
                    getAppBarUI(),
                    Expanded(
                      child: NestedScrollView(
                        controller: _scrollController,
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                return Column(
                                  children: <Widget>[
                                    getSearchBarUI(),
                                    getTimeDateUI(recentTransactionsBloc),
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
                          color:
                              PiggyAppTheme.buildLightTheme().backgroundColor,
                          child: BlocBuilder<RecentTransactionsBloc,
                              RecentTransactionsState>(
                            bloc: recentTransactionsBloc,
                            builder: (context, state) {
                              if (state is RecentTransactionsLoaded) {
                                _refreshCompleter?.complete();
                                _refreshCompleter = Completer();
                              }

                              return RefreshIndicator(
                                key: _refreshIndicatorKey,
                                onRefresh: () {
                                  recentTransactionsBloc.add(
                                    FetchRecentTransactions(
                                      input: GetTransactionsInput(
                                          type: 'tenant',
                                          accountId: null,
                                          startDate: startDate,
                                          endDate: endDate,
                                          groupBy: TransactionsGroupBy.Date),
                                    ),
                                  );
                                  return _refreshCompleter.future;
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
                                                    is RecentTransactionsLoading),

                                            // Fade in an Empty Result screen if the search contained
                                            // no items
                                            EmptyResultWidget(
                                                visible: state
                                                    is RecentTransactionsEmpty),

                                            // Fade in an error if something went wrong when fetching
                                            // the results
                                            ErrorDisplayWidget(
                                                visible: state
                                                    is RecentTransactionsError),

                                            // Fade in the Result if available
                                            TransactionList(
                                              items: state
                                                      is RecentTransactionsLoaded
                                                  ? state.filteredTransactions
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
            ],
          ),
          floatingActionButton: AddTransactionFab(),
        ),
      ),
    );
  }

  Widget getSearchBarUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: PiggyAppTheme.buildLightTheme().backgroundColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(38.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 8.0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 4, bottom: 4),
                  child: TextField(
                    onChanged: (String txt) {
                      recentTransactionsBloc.add(FilterRecentTransactions(txt));
                    },
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    cursorColor: PiggyAppTheme.buildLightTheme().primaryColor,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search...',
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: PiggyAppTheme.buildLightTheme().primaryColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(38.0),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    offset: const Offset(0, 2),
                    blurRadius: 8.0),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(32.0),
                ),
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(FontAwesomeIcons.search,
                      size: 20,
                      color: PiggyAppTheme.buildLightTheme().backgroundColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getTimeDateUI(RecentTransactionsBloc recentTransactionsBloc) {
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
                      // setState(() {
                      //   isDatePopupOpen = true;
                      // });
                      showDemoDialog(
                          context: context, bloc: recentTransactionsBloc);
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
                            style: TextStyle(
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
                          // BlocBuilder<AccountBloc, AccountState>(
                          //     bloc: accountBloc,
                          //     builder: (context, state) {
                          //       if (state is AccountLoaded) {
                          //         return Text(
                          //           ' ${state.account.currentBalance} ${state.account.currencySymbol}',
                          //           style: TextStyle(
                          //             fontWeight: FontWeight.w100,
                          //             fontSize: 16,
                          //           ),
                          //         );
                          //       }
                          //       if (state is AccountLoading) {
                          //         return Row(
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.spaceEvenly,
                          //           children: [
                          //             SpinKitWave(
                          //                 size: 16,
                          //                 color: PiggyAppTheme.buildLightTheme()
                          //                     .accentColor,
                          //                 type: SpinKitWaveType.start),
                          //             SpinKitWave(
                          //                 size: 16,
                          //                 color: PiggyAppTheme.buildLightTheme()
                          //                     .accentColor,
                          //                 type: SpinKitWaveType.center),
                          //             SpinKitWave(
                          //                 size: 16,
                          //                 color: PiggyAppTheme.buildLightTheme()
                          //                     .accentColor,
                          //                 type: SpinKitWaveType.end),
                          //           ],
                          //         );
                          //       }
                          //       return Text(
                          //         '---',
                          //         style: TextStyle(
                          //           fontWeight: FontWeight.w100,
                          //           fontSize: 16,
                          //         ),
                          //       );
                          //     })
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

  void showDemoDialog({BuildContext context, RecentTransactionsBloc bloc}) {
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
          bloc.add(FetchRecentTransactions(
              input: GetTransactionsInput(
                  type: 'tenant',
                  accountId: null,
                  startDate: startDate,
                  endDate: endDate,
                  groupBy: TransactionsGroupBy.Date)));
        },
        onCancelClick: () {},
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
                  child: BlocBuilder<RecentTransactionsBloc,
                          RecentTransactionsState>(
                      bloc: recentTransactionsBloc,
                      builder: (context, state) {
                        if (state is RecentTransactionsLoaded) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${state.filteredTransactions.transactions.length} transactions',
                              style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }
                        if (state is RecentTransactionsEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '0 transactions found',
                              style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        if (state is RecentTransactionsLoading) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SpinKitThreeBounce(
                              color:
                                  PiggyAppTheme.buildLightTheme().primaryColor,
                              size: 16,
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
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
                          Text(
                            'Filtter',
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

  Widget getAppBarUI() {
    return AppBar(
      title: Text('Recent Transactions'),
      actions: <Widget>[
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          onSelected: (value) {
            // print('PopupMenuButton onSelected $value');
            switch (value) {
              case 'TransactionsGroupBy.Category':
                {
                  recentTransactionsBloc.add(GroupRecentTransactions(
                      groupBy: TransactionsGroupBy.Category));
                }
                break;
              case 'TransactionsGroupBy.Date':
                {
                  recentTransactionsBloc.add(GroupRecentTransactions(
                      groupBy: TransactionsGroupBy.Date));
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'TransactionsGroupBy.Category',
              child: ListTile(
                leading: const Icon(Icons.category),
                title: const Text('View by category'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'TransactionsGroupBy.Date',
              child: ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('View by date'),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class ContestTabHeader extends SliverPersistentHeaderDelegate {
  ContestTabHeader(
    this.searchUI,
  );
  final Widget searchUI;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return searchUI;
  }

  @override
  double get maxExtent => 52.0;

  @override
  double get minExtent => 52.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
