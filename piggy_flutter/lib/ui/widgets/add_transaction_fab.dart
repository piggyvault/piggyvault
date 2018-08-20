import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/account_bloc.dart';
import 'package:piggy_flutter/bloc/account_detail_bloc.dart';
import 'package:piggy_flutter/bloc/transaction_bloc.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/providers/account_provider.dart';
import 'package:piggy_flutter/providers/transaction_provider.dart';
import 'package:piggy_flutter/ui/page/transaction/transaction_form.dart';

class AddTransactionFab extends StatelessWidget {
  final AccountDetailBloc accountDetailBloc;
  final Account account;
  const AddTransactionFab({Key key, this.accountDetailBloc, this.account})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AccountBloc accountBloc = AccountProvider.of(context);
    final TransactionBloc transactionBloc = TransactionProvider.of(context);

    return FloatingActionButton(
        key: ValueKey<Color>(Theme.of(context).primaryColor),
        tooltip: 'Add new transaction',
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () async {
          var result = await Navigator.push(
              context,
              MaterialPageRoute<DismissDialogAction>(
                builder: (BuildContext context) => TransactionFormPage(
                      account: account,
                    ),
                fullscreenDialog: true,
              ));

          if (result == DismissDialogAction.save) {
            if (accountDetailBloc != null) {
              accountDetailBloc.onPageChanged(0);
              accountDetailBloc.refreshAccount(true);
            }
            accountBloc.accountsRefresh(true);
            transactionBloc.recentTransactionsRefresh(true);
            transactionBloc.transactionSummaryRefresh('month');
          }
        });
  }
}
