import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/account_bloc.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/blocs/transaction_bloc.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/ui/screens/account/account_form.dart';
import 'package:piggy_flutter/ui/widgets/account_group_list.dart';
import 'package:piggy_flutter/utils/common.dart';

class AccountListPage extends StatelessWidget {
  AccountListPage({Key key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final AccountBloc _accountBloc = BlocProvider.of<AccountBloc>(context);
    final TransactionBloc _transactionBloc =
        BlocProvider.of<TransactionBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text('Accounts'),
      ),
      body: new RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: (() => _handleRefresh(_accountBloc)),
        child: new ListView(children: <Widget>[
          userAccountsBuilder(_accountBloc, _transactionBloc),
          familyAccountsBuilder(_accountBloc, _transactionBloc)
        ]),
      ),
      floatingActionButton: FloatingActionButton(
          key: ValueKey<Color>(Theme.of(context).buttonColor),
          tooltip: 'Add new account',
          backgroundColor: Colors.amber,
          child: Icon(Icons.add),
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute<DismissDialogAction>(
                  builder: (BuildContext context) => AccountFormScreen(
                        title: "Add Account",
                      ),
                  fullscreenDialog: true,
                ));
          }),
    );
  }

  Widget userAccountsBuilder(
          AccountBloc accountBloc, TransactionBloc transactionBloc) =>
      StreamBuilder<List<Account>>(
        stream: accountBloc.userAccounts,
        builder: (context, snapshot) => AccountGroupList(
              accounts: snapshot.hasData ? snapshot.data : null,
              title: 'Your Accounts',
              transactionBloc: transactionBloc,
            ),
      );

  Widget familyAccountsBuilder(
          AccountBloc accountBloc, TransactionBloc transactionBloc) =>
      StreamBuilder<List<Account>>(
        stream: accountBloc.familyAccounts,
        builder: (context, snapshot) => AccountGroupList(
              accounts: snapshot.hasData ? snapshot.data : null,
              title: 'Family Accounts',
              transactionBloc: transactionBloc,
            ),
      );

  Future<Null> _handleRefresh(AccountBloc accountBloc) {
    return accountBloc.getTenantAccounts(true).then((_) {
      _scaffoldKey.currentState?.showSnackBar(
        new SnackBar(content: const Text('Refresh complete')),
      );
    });
  }
}
