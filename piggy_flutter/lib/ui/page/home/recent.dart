import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/blocs/transaction_bloc.dart';
import 'package:piggy_flutter/model/recent_transactions_state.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';
import 'package:piggy_flutter/ui/widgets/add_transaction_fab.dart';
import 'package:piggy_flutter/ui/widgets/common/empty_result_widget.dart';
import 'package:piggy_flutter/ui/widgets/common/error_display_widget.dart';
import 'package:piggy_flutter/ui/widgets/common/loading_widget.dart';
import 'package:piggy_flutter/ui/widgets/transaction_list.dart';

class RecentPage extends StatelessWidget {
  RecentPage({Key key}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final TransactionBloc transactionBloc =
        BlocProvider.of<TransactionBloc>(context);

    return StreamBuilder<RecentTransactionsState>(
      stream: transactionBloc.recentTransactionsState,
      initialData: RecentTransactionsLoading(),
      builder: (BuildContext context,
          AsyncSnapshot<RecentTransactionsState> snapshot) {
        final state = snapshot.data;
        return Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            title: Text('Recent Transactions'),
            actions: <Widget>[
              new IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _handleRefresh(transactionBloc);
                },
              ),
              new PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  print('PopupMenuButton onSelected $value');
                  switch (value) {
                    case 'TransactionsGroupBy.Category':
                      {
                        transactionBloc.changeTransactionsGroupBy(
                            TransactionsGroupBy.Category);
                      }
                      break;
                    case 'TransactionsGroupBy.Date':
                      {
                        transactionBloc.changeTransactionsGroupBy(
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
          body: new RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: (() => _handleRefresh(transactionBloc)),
            child: SafeArea(
              top: false,
              bottom: false,
              child: new Column(
                children: <Widget>[
                  new Expanded(
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
                              ? state.result.items
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

  Future<Null> _handleRefresh(TransactionBloc transactionBloc) {
    return transactionBloc.getRecentTransactions(true).then((_) {
      _scaffoldKey.currentState?.showSnackBar(
        new SnackBar(
          content: const Text('Refresh complete'),
          action: new SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              }),
        ),
      );
    });
  }
}
