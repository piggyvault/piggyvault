import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/transaction_bloc.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/ui/pages/account/account_detail.dart';

class AccountGroupList extends StatelessWidget {
  final List<Account> accounts;
  final String title;
  final TransactionBloc transactionBloc;

  AccountGroupList(
      {@required this.accounts,
      @required this.title,
      @required this.transactionBloc});

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

  buildAccountListTile(BuildContext context, Account account) {
    return MergeSemantics(
      child: ListTile(
        dense: true,
        leading: Icon(Icons.account_balance_wallet,
            color: Theme.of(context).disabledColor),
        title: Text(account.name),
        subtitle: Text(account.accountType),
        trailing: Text('${account.currentBalance
            .toString()} ${account.currencySymbol}'),
        onTap: (() => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AccountDetailPage(
                        account: account,
                        syncStream: transactionBloc.syncStream,
                      )),
            )),
      ),
    );
  }
}
