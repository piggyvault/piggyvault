import 'package:flutter/material.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/bloc/account_bloc.dart';
import 'package:piggy_flutter/services/account_service.dart';
import 'package:piggy_flutter/ui/page/transaction/transaction_form.dart';
import 'package:piggy_flutter/ui/widgets/account/account_group_list.dart';

class AccountListPage extends StatelessWidget {
  final AccountBloc accountBloc = new AccountBloc();

  @override
  Widget build(BuildContext context) {
    print("########## AccountListPage  build");
    accountBloc.refreshAccounts.add(true);

    return Scaffold(
      body: new ListView(
          children: <Widget>[userAccountsBuilder(), familyAccountsBuilder()]),
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

  Widget userAccountsBuilder() => StreamBuilder<List<Account>>(
      stream: accountBloc.userAccounts,
      builder: (context, snapshot) => AccountGroupList(
          snapshot.hasData ? snapshot.data : null, 'Your Accounts'));

  Widget familyAccountsBuilder() => StreamBuilder<List<Account>>(
      stream: accountBloc.familyAccounts,
      builder: (context, snapshot) => AccountGroupList(
          snapshot.hasData ? snapshot.data : null, 'Family Accounts'));

  AccountListPage({Key key}) : super(key: key);
}
