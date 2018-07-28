import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/transaction_bloc.dart';
import 'package:piggy_flutter/model/transaction.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:piggy_flutter/ui/widgets/transaction_list.dart';


class RecentPage extends StatelessWidget {
  RecentPage({Key key}) : super(key: key);

  final TransactionBloc transactionBloc = new TransactionBloc();

  @override
  Widget build(BuildContext context) {
    transactionBloc.recentTransactionSink.add(GetTransactionsInput(
        'tenant',
        null,
        new DateTime.now().add(new Duration(days: -30)).toString(),
        new DateTime.now().add(new Duration(days: 1)).toString(),
        'recent'));

    return Scaffold(body: transactionListBuilder());
  }

  Widget transactionListBuilder() => StreamBuilder<List<TransactionGroupItem>>(
        stream: transactionBloc.recentTransactions,
        initialData: [],
        builder: (context, snapshot) =>
            TransactionList(snapshot.hasData ? snapshot.data : null),
      );
}


