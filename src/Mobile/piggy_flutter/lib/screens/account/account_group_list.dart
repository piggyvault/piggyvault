import 'package:flutter/material.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/screens/account/account_detail.dart';

class AccountGroupList extends StatelessWidget {
  final List<Account> accounts;
  final String title;

  AccountGroupList({@required this.accounts, @required this.title});

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> accountTiles;
    if (accounts == null) {
      accountTiles = [new Center(child: LinearProgressIndicator())];
    } else {
      accountTiles =
          accounts.map((dynamic item) => buildAccountListTile(context, item));
    }

    return ExpansionTile(
        key: PageStorageKey(this.title),
        title: Text(this.title,
            style: Theme.of(context).textTheme.title.copyWith(
                fontSize: 16.0, color: Theme.of(context).accentColor)),
        initiallyExpanded: true,
        backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
        children: accountTiles.toList());
  }

  buildAccountListTile(BuildContext context, Account account) {
    return MergeSemantics(
      child: ListTile(
        dense: true,
        leading: Icon(Icons.account_balance_wallet,
            color: Theme.of(context).disabledColor),
        title: Text(account.name, style: Theme.of(context).textTheme.body2),
        subtitle: Text(account.accountType),
        trailing: Text(
            '${account.currentBalance.toString()} ${account.currencySymbol}'),
        onTap: (() => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AccountDetailPage(account: account)),
            )),
      ),
    );
  }
}
