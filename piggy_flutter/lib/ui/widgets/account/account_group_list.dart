import 'package:flutter/material.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/ui/page/account/account_detail.dart';

class AccountGroupList extends StatelessWidget {
  final List<Account> accounts;
  final String title;

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> accountTiles;
    if (accounts == null) {
      accountTiles = [new Center(child: LinearProgressIndicator())];
    } else {
      accountTiles =
          accounts.map((dynamic item) => buildAccountListTile(context, item));
    }

    return new ExpansionTile(
        key: PageStorageKey('YourAccounts'),
        title: Text(this.title),
        initiallyExpanded: true,
        backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
        children: accountTiles.toList());
  }

  AccountGroupList(this.accounts, this.title);

  buildAccountListTile(BuildContext context, Account account) {
    return new MergeSemantics(
      child: new ListTile(
        dense: true,
        leading: new Icon(Icons.account_balance_wallet,
            color: Theme.of(context).disabledColor),
        title: new Text(account.name),
        subtitle: new Text(account.accountType),
        trailing: new Text('${account.currentBalance
            .toString()} ${account.currencySymbol}'),
        onTap: (() => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AccountDetailPage(
                        account: account,
                      )),
            )),
      ),
    );
  }
}
