import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/screens/account/account_detail.dart';

class AccountGroupList extends StatelessWidget {
  const AccountGroupList({@required this.accounts, @required this.title});

  final List<Account> accounts;
  final String title;

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> accountTiles;

    if (accounts == null) {
      accountTiles = [const Center(child: LinearProgressIndicator())];
    } else {
      accountTiles =
          accounts.map((dynamic item) => buildAccountListTile(context, item));
    }

    return ExpansionTile(
        title: Text(title,
            style: Theme.of(context).textTheme.title.copyWith(
                fontSize: 16.0, color: Theme.of(context).accentColor)),
        initiallyExpanded: true,
        backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
        children: accountTiles.toList());
  }

  Widget buildAccountListTile(BuildContext context, Account account) {
    return MergeSemantics(
      child: ListTile(
        dense: true,
        leading: Icon(Icons.account_balance_wallet,
            color: Theme.of(context).disabledColor),
        title: Text(account.name, style: Theme.of(context).textTheme.body2),
        subtitle: Text(account.accountType),
        trailing: Text(
            '${account.currentBalance.toString()} ${account.currencySymbol}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<AccountDetailPage>(
            builder: (BuildContext context) => AccountDetailPage(
              account: account,
              accountRepository:
                  RepositoryProvider.of<AccountRepository>(context),
              transactionRepository:
                  RepositoryProvider.of<TransactionRepository>(context),
            ),
          ),
        ),
      ),
    );
  }
}
