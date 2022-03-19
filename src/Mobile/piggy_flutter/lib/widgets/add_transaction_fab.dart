import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/screens/transaction/transaction_form.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/common.dart';

class AddTransactionFab extends StatelessWidget {
  const AddTransactionFab({Key? key, this.account}) : super(key: key);
  final Account? account;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        key: ValueKey<Color>(Theme.of(context).primaryColor),
        tooltip: 'Add new transaction',
        backgroundColor: PiggyAppTheme.nearlyDarkBlue,
        child: Icon(
          Icons.add,
          color: PiggyAppTheme.buildLightTheme().indicatorColor,
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
            ),
          );
        });
  }
}
