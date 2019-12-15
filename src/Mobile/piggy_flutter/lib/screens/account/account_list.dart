import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts.dart';
import 'package:piggy_flutter/blocs/accounts/accounts_bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts_state.dart';
import 'package:piggy_flutter/screens/account/account_group_list.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({Key key}) : super(key: key);

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: BlocBuilder<AccountsBloc, AccountsState>(
        builder: (BuildContext context, AccountsState state) {
          if (state is AccountsLoading) {
            return const Center(child: CircularProgressIndicator());
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
              child: ListView(children: <Widget>[
                AccountGroupList(
                    accounts: state.userAccounts, title: 'Your Accounts'),
                AccountGroupList(
                    accounts: state.familyAccounts, title: 'Family Accounts')
              ]),
            );
          }
          return const Center(child: Text('Accounts'));
        },
      ),
    );
  }
}
