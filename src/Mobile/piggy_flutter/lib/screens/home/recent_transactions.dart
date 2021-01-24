import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/recent_transactions/bloc.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/models/transaction_group_item.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/widgets/common/calendar_popup_view.dart';
import 'package:piggy_flutter/widgets/common/common.dart';
import 'package:piggy_flutter/widgets/common/empty_result_widget.dart';
import 'package:piggy_flutter/widgets/common/error_display_widget.dart';
import 'package:piggy_flutter/widgets/common/loading_widget.dart';
import 'package:piggy_flutter/widgets/transaction_list.dart';

class RecentTransactionsPage extends StatefulWidget {
  const RecentTransactionsPage({Key key, @required this.animationController})
      : super(key: key);

  final AnimationController animationController;

  @override
  _RecentTransactionsPageState createState() => _RecentTransactionsPageState();
}

class _RecentTransactionsPageState extends State<RecentTransactionsPage>
    with TickerProviderStateMixin {
  Animation<double> topBarAnimation;
  Animation<double> listAnimation;

  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  List<Widget> listViews = <Widget>[];

  Completer<void> _refreshCompleter;
  RecentTransactionsBloc recentTransactionsBloc;

  DateTime startDate = DateTime.now().add(const Duration(days: -30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );

    listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)));

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

    recentTransactionsBloc = BlocProvider.of<RecentTransactionsBloc>(context);

    _refreshCompleter = Completer<void>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PiggyAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getMainListViewUI(),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
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
            widget.animationController.forward();
            return AnimatedBuilder(
                animation: widget.animationController,
                builder: (BuildContext context, Widget child) {
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
                              bottom:
                                  62 + MediaQuery.of(context).padding.bottom,
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
                                              (BuildContext context,
                                                  int index) {
                                            return Column(
                                              children: <Widget>[
                                                getSearchBarUI(),
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
                                      child: BlocBuilder<RecentTransactionsBloc,
                                          RecentTransactionsState>(
                                        cubit: recentTransactionsBloc,
                                        builder: (BuildContext context,
                                            RecentTransactionsState state) {
                                          if (state
                                              is RecentTransactionsLoaded) {
                                            _refreshCompleter?.complete();
                                            _refreshCompleter =
                                                Completer<void>();
                                          }

                                          return RefreshIndicator(
                                            onRefresh: () {
                                              recentTransactionsBloc.add(
                                                FetchRecentTransactions(
                                                  input: GetTransactionsInput(
                                                      type: 'tenant',
                                                      accountId: null,
                                                      startDate: startDate,
                                                      endDate: endDate,
                                                      groupBy:
                                                          TransactionsGroupBy
                                                              .Date),
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
                                                              ? state
                                                                  .filteredTransactions
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
                      ));
                });
          }
        });
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
                  child: Icon(FontAwesome5Solid.search_dollar,
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
                      cubit: recentTransactionsBloc,
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
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController,
          builder: (BuildContext context, Widget child) {
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
                                child: Text(
                                  'Recent',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: PiggyAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: PiggyAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: PiggyAppTheme.grey,
                                      size: 18,
                                    ),
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
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        // setState(() {
                                        //   isDatePopupOpen = true;
                                        // });
                                        showDemoDialog(
                                            context: context,
                                            bloc: recentTransactionsBloc);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                            top: 4,
                                            bottom: 4),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              '${DateFormat("dd, MMM").format(startDate)} - ${DateFormat("dd, MMM").format(endDate)}',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontFamily:
                                                    PiggyAppTheme.fontName,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 18,
                                                letterSpacing: -0.2,
                                                color: PiggyAppTheme.darkerText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
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

  Widget getAppBarUIOld() {
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
