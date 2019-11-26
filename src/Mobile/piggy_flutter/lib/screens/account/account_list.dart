import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts.dart';
import 'package:piggy_flutter/blocs/accounts/accounts_bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts_state.dart';
import 'package:piggy_flutter/screens/account/account_form.dart';
import 'package:piggy_flutter/screens/account/account_group_list.dart';
import 'package:piggy_flutter/utils/common.dart';

class AccountListPage extends StatefulWidget {
  AccountListPage({Key key}) : super(key: key);

  @override
  _AccountListPageState createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text('Accounts'),
      ),
      body: BlocBuilder<AccountsBloc, AccountsState>(builder: (context, state) {
        if (state is AccountsLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is AccountsLoaded) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();

          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () {
              BlocProvider.of<AccountsBloc>(context).add(LoadAccounts());
              return _refreshCompleter.future;
            },
            child: new ListView(children: <Widget>[
              AccountGroupList(
                  accounts: state.userAccounts, title: 'Your Accounts'),
              AccountGroupList(
                  accounts: state.familyAccounts, title: 'Family Accounts')
            ]),
          );
        }
        return Center(child: Text('Accounts'));
      }),
      floatingActionButton: FloatingActionButton(
          key: ValueKey<Color>(Theme.of(context).buttonColor),
          tooltip: 'Add new account',
          backgroundColor: Colors.amber,
          child: Icon(
            Icons.add,
            color: Theme.of(context).primaryColor,
          ),
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
}
