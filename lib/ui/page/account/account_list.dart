import 'package:flutter/material.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/bloc/account_bloc.dart';
import 'package:piggy_flutter/services/account_service.dart';
import 'package:piggy_flutter/ui/widgets/account/account_group_list.dart';

class AccountListPage extends StatelessWidget {
  final AccountService _accountService = new AccountService();
  final AccountBloc accountBloc = new AccountBloc();

  @override
  Widget build(BuildContext context) {
    accountBloc.accounts.add(_accountService);
    return new ListView(children: <Widget>[
      userAccountsBuilder(),
      familyAccountsBuilder()
    ]);
  }

  Widget userAccountsBuilder() => StreamBuilder<List<Account>>(
      stream: accountBloc.userAccounts,
      initialData: [],
      builder: (context, snapshot) => AccountGroupList(
          snapshot.hasData ? snapshot.data : null, 'Your Accounts'));

  Widget familyAccountsBuilder() => StreamBuilder<List<Account>>(
      stream: accountBloc.familyAccounts,
      initialData: [],
      builder: (context, snapshot) => AccountGroupList(
          snapshot.hasData ? snapshot.data : null, 'Family Accounts'));

  AccountListPage({Key key}) : super(key: key);
}

