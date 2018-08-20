import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/bloc/account_bloc.dart';
import 'package:piggy_flutter/providers/account_provider.dart';
import 'package:piggy_flutter/ui/widgets/account/account_group_list.dart';
import 'package:piggy_flutter/ui/widgets/add_transaction_fab.dart';

class AccountListPage extends StatelessWidget {
  AccountListPage({Key key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final AccountBloc accountBloc = AccountProvider.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text('Accounts'),
      ),
      body: new RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: (() => _handleRefresh(accountBloc)),
        child: new ListView(children: <Widget>[
          userAccountsBuilder(accountBloc),
          familyAccountsBuilder(accountBloc)
        ]),
      ),
      floatingActionButton: AddTransactionFab(),
    );
  }

  Widget userAccountsBuilder(AccountBloc accountBloc) =>
      StreamBuilder<List<Account>>(
        stream: accountBloc.userAccounts,
        builder: (context, snapshot) => AccountGroupList(
            snapshot.hasData ? snapshot.data : null, 'Your Accounts'),
      );

  Widget familyAccountsBuilder(AccountBloc accountBloc) =>
      StreamBuilder<List<Account>>(
        stream: accountBloc.familyAccounts,
        builder: (context, snapshot) => AccountGroupList(
            snapshot.hasData ? snapshot.data : null, 'Family Accounts'),
      );

  Future<Null> _handleRefresh(AccountBloc accountBloc) {
    return accountBloc.getTenantAccounts(true).then((_) {
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
