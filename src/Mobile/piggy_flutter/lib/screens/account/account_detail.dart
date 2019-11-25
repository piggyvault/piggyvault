import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/account_transactions/bloc.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/models/get_transactions_input.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/widgets/common/calendar_popup_view.dart';
import 'package:piggy_flutter/widgets/common/empty_result_widget.dart';
import 'package:piggy_flutter/widgets/common/error_display_widget.dart';
import 'package:piggy_flutter/widgets/common/loading_widget.dart';
import 'package:piggy_flutter/widgets/transaction_list.dart';

class AccountDetailPage extends StatefulWidget {
  final Account account;
  final TransactionRepository transactionRepository;

  AccountDetailPage(
      {Key key, @required this.account, @required this.transactionRepository})
      : super(key: key);

  @override
  _AccountDetailPageState createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage>
    with TickerProviderStateMixin {
  AnimationController animationController;
  final ScrollController _scrollController = ScrollController();
  AccountTransactionsBloc accountTransactionsBloc;

  DateTime startDate = DateTime.now().add(const Duration(days: -30));
  DateTime endDate = DateTime.now();

  // AccountDetailBloc _bloc;
  // StreamSubscription _subscription;

  @override
  void initState() {
    accountTransactionsBloc = AccountTransactionsBloc(
        transactionRepository: widget.transactionRepository);

    accountTransactionsBloc.add(FetchAccountTransactions(
        input: GetTransactionsInput(
            type: 'account',
            accountId: widget.account.id,
            startDate: startDate,
            endDate: endDate,
            groupBy: TransactionsGroupBy.Date)));
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    super.initState();
    // _bloc = AccountDetailBloc(accountId: widget.account.id);
    // _bloc.changeAccount(widget.account);
    // _bloc.onPageChanged(0);
  }

  @override
  void dispose() {
    animationController.dispose();

    // _bloc.dispose();
    // _subscription?.cancel();
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
                                    // getSearchBarUI(),
                                    getTimeDateUI(accountTransactionsBloc),
                                  ],
                                );
                              }, childCount: 1),
                            ),
                            // SliverPersistentHeader(
                            //   pinned: true,
                            //   floating: true,
                            //   delegate: ContestTabHeader(
                            //     getFilterBarUI(),
                            //   ),
                            // ),
                          ];
                        },
                        body: Container(
                          color:
                              PiggyAppTheme.buildLightTheme().backgroundColor,
                          child: BlocBuilder<AccountTransactionsBloc,
                                  AccountTransactionsState>(
                              bloc: accountTransactionsBloc,
                              builder: (context, state) {
                                return SafeArea(
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
                                                  ? state.result.sections
                                                  : [],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          // child: ListView.builder(
                          //   itemCount: hotelList.length,
                          //   padding: const EdgeInsets.only(top: 8),
                          //   scrollDirection: Axis.vertical,
                          //   itemBuilder: (BuildContext context, int index) {
                          //     final int count =
                          //         hotelList.length > 10 ? 10 : hotelList.length;
                          //     final Animation<double> animation =
                          //         Tween<double>(begin: 0.0, end: 1.0).animate(
                          //             CurvedAnimation(
                          //                 parent: animationController,
                          //                 curve: Interval(
                          //                     (1 / count) * index, 1.0,
                          //                     curve: Curves.fastOutSlowIn)));
                          //     animationController.forward();
                          //     return HotelListView(
                          //       callback: () {},
                          //       hotelData: hotelList[index],
                          //       animation: animation,
                          //       animationController: animationController,
                          //     );
                          //   },
                          // ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getAppBarUI() {
    return AppBar(
        //     title: Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: <Widget>[
        //     Padding(
        //       padding: const EdgeInsets.only(top: 8.0),
        //       child: Text(account.name),
        //     ),
        //     Text(
        //       ' ${account.currentBalance} ${account.currencySymbol}',
        //       style: Theme.of(context)
        //           .textTheme
        //           .body2
        //           .copyWith(color: Theme.of(context).accentColor),
        //     )
        //   ],
        // )
        );
  }

  Widget getTimeDateUI(AccountTransactionsBloc accountTransactionsBloc) {
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
                            'Number of Rooms',
                            style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 16,
                                color: Colors.grey.withOpacity(0.8)),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            '1 Room - 2 Adults',
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
        ],
      ),
    );
  }

  void showDemoDialog({BuildContext context, AccountTransactionsBloc bloc}) {
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
          bloc.add(FetchAccountTransactions(
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
  // @override
  // Widget build(BuildContext context) {
  //   final TextTheme textTheme = Theme.of(context).textTheme;

  //   return StreamBuilder<AccountDetailState>(
  //       stream: _bloc.state,
  //       initialData: AccountDetailLoading(),
  //       builder:
  //           (BuildContext context, AsyncSnapshot<AccountDetailState> snapshot) {
  //         final state = snapshot.data;
  //         final account =
  //             state.account == null ? widget.account : state.account;
  //         return Scaffold(
  //           appBar: AppBar(
  //             title: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 8.0),
  //                   child: Text(account.name),
  //                 ),
  //                 Text(
  //                   ' ${account.currentBalance} ${account.currencySymbol}',
  //                   style: Theme.of(context)
  //                       .textTheme
  //                       .body2
  //                       .copyWith(color: Theme.of(context).accentColor),
  //                 )
  //               ],
  //             ),
  //             bottom: PreferredSize(
  //               preferredSize: const Size.fromHeight(48.0),
  //               child: Container(
  //                 margin: EdgeInsets.all(16.0),
  //                 child: Row(
  //                   children: <Widget>[
  //                     InkWell(
  //                       child: Text(state.previousPageTitle,
  //                           style: textTheme.caption),
  //                       onTap: () {
  //                         _bloc.onPageChanged(-1);
  //                       },
  //                     ),
  //                     Text(
  //                       state.title,
  //                       style: textTheme.body2,
  //                     ),
  //                     InkWell(
  //                       child:
  //                           Text(state.nextPageTitle, style: textTheme.caption),
  //                       onTap: () {
  //                         _bloc.onPageChanged(1);
  //                       },
  //                     ),
  //                   ],
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                 ),
  //               ),
  //             ),
  //             actions: <Widget>[
  //               PopupMenuButton<String>(
  //                 padding: EdgeInsets.zero,
  //                 onSelected: (value) {
  //                   // print('PopupMenuButton onSelected $value');
  //                   switch (value) {
  //                     case UIData.account_edit:
  //                       {
  //                         Navigator.push(
  //                             context,
  //                             MaterialPageRoute<DismissDialogAction>(
  //                               builder: (BuildContext context) =>
  //                                   AccountFormScreen(
  //                                 account: widget.account,
  //                                 title: 'Edit Account',
  //                               ),
  //                               fullscreenDialog: true,
  //                             ));
  //                       }
  //                       break;
  //                   }
  //                 },
  //                 itemBuilder: (BuildContext context) =>
  //                     <PopupMenuEntry<String>>[
  //                   const PopupMenuItem<String>(
  //                     value: UIData.account_edit,
  //                     child: ListTile(
  //                       leading: Icon(Icons.edit),
  //                       title: Text(UIData.edit),
  //                     ),
  //                   ),
  //                   const PopupMenuItem<String>(
  //                     value: UIData.adjust_balance,
  //                     child: ListTile(
  //                       leading: Icon(Icons.account_balance),
  //                       title: Text(UIData.adjust_balance),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),

  //           floatingActionButton: AddTransactionFab(
  //             account: widget.account,
  //           ),
  //         );
  //       });
  // }
}
