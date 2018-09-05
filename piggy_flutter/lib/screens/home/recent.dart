import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/models/recent_transactions_state.dart';
import 'package:piggy_flutter/models/transaction_group_item.dart';
import 'package:piggy_flutter/screens/home/home_bloc.dart';
import 'package:piggy_flutter/widgets/add_transaction_fab.dart';
import 'package:piggy_flutter/widgets/common/empty_result_widget.dart';
import 'package:piggy_flutter/widgets/common/error_display_widget.dart';
import 'package:piggy_flutter/widgets/common/loading_widget.dart';
import 'package:piggy_flutter/widgets/transaction_list.dart';

class RecentPage extends StatelessWidget {
  RecentPage({Key key}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final HomeBloc bloc = BlocProvider.of<HomeBloc>(context);

    return StreamBuilder<RecentTransactionsState>(
      stream: bloc.recentTransactionsState,
      initialData: RecentTransactionsLoading(),
      builder: (BuildContext context,
          AsyncSnapshot<RecentTransactionsState> snapshot) {
        final state = snapshot.data;
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              'Recent Transactions',
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _handleRefresh(bloc);
                },
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  // print('PopupMenuButton onSelected $value');
                  switch (value) {
                    case 'TransactionsGroupBy.Category':
                      {
                        bloc.changeTransactionsGroupBy(
                            TransactionsGroupBy.Category);
                      }
                      break;
                    case 'TransactionsGroupBy.Date':
                      {
                        bloc.changeTransactionsGroupBy(
                            TransactionsGroupBy.Date);
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
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: (() => _handleRefresh(bloc)),
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
                          items: state is RecentTransactionsPopulated
                              ? state.result.sections
                              : [],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: AddTransactionFab(),
        );
      },
    );
  }

  Future<Null> _handleRefresh(HomeBloc bloc) {
    return bloc.getRecentTransactions().then((_) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: const Text('Refresh complete'),
          action: SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              }),
        ),
      );
    });
  }
}
