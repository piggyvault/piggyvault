import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/recent_transactions/bloc.dart';
import 'package:piggy_flutter/models/transaction_group_item.dart';
import 'package:piggy_flutter/widgets/add_transaction_fab.dart';
import 'package:piggy_flutter/widgets/common/empty_result_widget.dart';
import 'package:piggy_flutter/widgets/common/error_display_widget.dart';
import 'package:piggy_flutter/widgets/common/loading_widget.dart';
import 'package:piggy_flutter/widgets/transaction_list.dart';

class RecentPage extends StatefulWidget {
  RecentPage({Key key}) : super(key: key);

  @override
  _RecentPageState createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> {
  Completer<void> _refreshCompleter;
  RecentTransactionsBloc bloc;
  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<RecentTransactionsBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Recent Transactions',
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            onSelected: (value) {
              // print('PopupMenuButton onSelected $value');
              switch (value) {
                case 'TransactionsGroupBy.Category':
                  {
                    bloc.add(GroupRecentTransactions(
                        groupBy: TransactionsGroupBy.Category));
                  }
                  break;
                case 'TransactionsGroupBy.Date':
                  {
                    bloc.add(GroupRecentTransactions(
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
      ),
      body: BlocBuilder<RecentTransactionsBloc, RecentTransactionsState>(
          bloc: bloc,
          builder: (context, state) {
            if (state is RecentTransactionsLoaded) {
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }

            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () {
                bloc.add(LoadRecentTransactions());
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
                              visible: state is RecentTransactionsLoading),

                          // Fade in an Empty Result screen if the search contained
                          // no items
                          EmptyResultWidget(
                              visible: state is RecentTransactionsEmpty),

                          // Fade in an error if something went wrong when fetching
                          // the results
                          ErrorDisplayWidget(
                              visible: state is RecentTransactionsError),

                          // Fade in the Result if available
                          TransactionList(
                            items: state is RecentTransactionsLoaded
                                ? state.result.sections
                                : [],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: AddTransactionFab(),
    );
  }
}
