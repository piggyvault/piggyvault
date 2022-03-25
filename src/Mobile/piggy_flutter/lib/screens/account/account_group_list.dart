import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import 'package:piggy_flutter/screens/account/account_detail.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/common.dart';

class AccountGroupList extends StatelessWidget {
  const AccountGroupList(
      {required this.accounts,
      required this.title,
      required this.animationController});

  final List<Account>? accounts;
  final String title;
  final AnimationController? animationController;

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> accountTiles;

    if (accounts == null) {
      accountTiles = [const Center(child: LinearProgressIndicator())];
    } else {
      accountTiles =
          accounts!.map((dynamic item) => buildAccountListTile(context, item));
    }

    return ExpansionTile(
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(fontSize: 16.0, color: Theme.of(context).accentColor),
        ),
        initiallyExpanded: true,
        backgroundColor: PiggyAppTheme.white,
        children: accountTiles.toList());
  }

  Widget buildAccountListTile(BuildContext context, Account account) {
    return MergeSemantics(
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.account_balance_wallet,
          color: Theme.of(context).disabledColor,
        ),
        title:
            Text(account.name!, style: Theme.of(context).textTheme.bodyText1),
        subtitle: Text(
          account.accountType!,
        ),
        trailing: account.isArchived
            ? const Chip(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                label: Text(
                  "ARCHIVED",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Text(
                '${account.currentBalance.toMoney()} ${account.currencySymbol}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<AccountDetailPage>(
            builder: (BuildContext context) => AccountDetailPage(
              animationController: animationController,
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
