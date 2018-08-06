import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/bloc/account_bloc.dart';
import 'package:piggy_flutter/providers/account_provider.dart';
import 'package:piggy_flutter/ui/page/transaction/transaction_form.dart';
import 'package:piggy_flutter/ui/widgets/account/account_group_list.dart';

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
      floatingActionButton: new FloatingActionButton(
          key: new ValueKey<Color>(Theme.of(context).primaryColor),
          tooltip: 'Add new transaction',
          backgroundColor: Theme.of(context).primaryColor,
          child: new Icon(Icons.add_circle_outline),
          onPressed: () {
            Navigator.push(
                context,
                new MaterialPageRoute<DismissDialogAction>(
                  builder: (BuildContext context) => new TransactionFormPage(),
                  fullscreenDialog: true,
                ));
          }),
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
