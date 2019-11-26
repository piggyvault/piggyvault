import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/screens/transaction/transaction_form.dart';
import 'package:piggy_flutter/utils/common.dart';

class AddTransactionFab extends StatelessWidget {
  final Account account;
  const AddTransactionFab({Key key, this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        key: ValueKey<Color>(Theme.of(context).primaryColor),
        tooltip: 'Add new transaction',
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(
          Icons.add,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute<DismissDialogAction>(
                builder: (BuildContext context) => TransactionFormPage(
                  transactionsBloc: BlocProvider.of<TransactionBloc>(context),
                  account: account,
                ),
                fullscreenDialog: true,
              ));
        });
  }
}
