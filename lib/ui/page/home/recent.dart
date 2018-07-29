import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/transaction_bloc.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';
import 'package:piggy_flutter/ui/page/transaction/transaction_form.dart';
import 'package:piggy_flutter/ui/widgets/transaction_list.dart';

class RecentPage extends StatelessWidget {
  RecentPage({Key key}) : super(key: key);

  final TransactionBloc transactionBloc = new TransactionBloc();

  @override
  Widget build(BuildContext context) {
    print('########## RecentPage build');
    transactionBloc.refreshRecentTransactionsSink.add(true);

    return Scaffold(
      body: transactionListBuilder(),
      floatingActionButton: new FloatingActionButton(
          key: new ValueKey<Color>(Theme.of(context).primaryColor),
          tooltip: 'Add new transaction',
          backgroundColor: Theme.of(context).primaryColor,
          child: new Icon(Icons.add_circle_outline),
          onPressed: () {
            Navigator.push(
                context,
                new MaterialPageRoute<DismissDialogAction>(
                  builder: (BuildContext context) => new TransactionFormPage(),
                  fullscreenDialog: true,
                ));
          }),
    );
  }

  Widget transactionListBuilder() => StreamBuilder<List<TransactionGroupItem>>(
        stream: transactionBloc.recentTransactions,
        initialData: [],
        builder: (context, snapshot) =>
            TransactionList(snapshot.hasData ? snapshot.data : null),
      );
}
