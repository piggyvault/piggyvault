import 'package:flutter/material.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/ui/widgets/common/message_placeholder.dart';

class AccountGroupList extends StatelessWidget {
  final List<Account> accounts;
  final String title;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (accounts == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      if (accounts.length > 0) {
        return _buildList(context);
      } else {
        return MessagePlaceholder();
      }
    }
  }

  AccountGroupList(this.accounts, this.title);

  Widget _buildList(BuildContext context) {
    Iterable<Widget> userAccountsTiles =
        accounts.map((dynamic item) => buildAccountListTile(context, item));

    return ExpansionTile(
        key: PageStorageKey('YourAccounts'),
        title: Text(this.title),
        initiallyExpanded: true,
        backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
        children: userAccountsTiles.toList());
  }

  buildAccountListTile(BuildContext context, Account item) {
    return new MergeSemantics(
      child: new ListTile(
        dense: true,
        leading: new Icon(Icons.account_balance_wallet,
            color: Theme.of(context).disabledColor),
        title: new Text(item.name),
        subtitle: new Text(item.accountType),
        trailing: new Text('${item.currentBalance
            .toString()} ${item.currencySymbol}'),
      ),
    );
  }
}
