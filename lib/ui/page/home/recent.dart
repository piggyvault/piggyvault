import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/transaction_bloc.dart';
import 'package:piggy_flutter/model/transaction.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';
import 'package:piggy_flutter/services/transaction_service.dart';


class RecentPage extends StatelessWidget {
  RecentPage({Key key}) : super(key: key);

  final TransactionBloc transactionBloc = new TransactionBloc();

  @override
  Widget build(BuildContext context) {
    transactionBloc.recentTransactionSink.add(GetTransactionsInput(
        'tenant',
        null,
        new DateTime.now().add(new Duration(days: -100)).toString(),
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

class TransactionList extends StatelessWidget {
  final List<TransactionGroupItem> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      if (transactions.length > 0) {
        Iterable<Widget> groupedTransactionList = transactions
            .map((item) => buildGroupedTransactionTile(context, item));
        return ListView(
          children: groupedTransactionList.toList(),
        );
      } else {
        return new Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.sentiment_dissatisfied,
                size: 100.0,
//              color: iconColor,
              ),
              SizedBox(
                height: 20.0,
              ),
              Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Nothing found',
                    style: TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.w700,
//                  color: textColor
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'Add items',
                    style: TextStyle(
                      fontSize: 15.0, fontWeight: FontWeight.normal,
//                  color: textColor
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }
    }
  }

  buildGroupedTransactionTile(BuildContext context, TransactionGroupItem item) {
    Iterable<Widget> transactionList = item.transactions
        .map((transaction) => buildTransactionList(context, transaction));

    return ExpansionTile(
        key: PageStorageKey(item.index),
        title: Text(item.title),
        initiallyExpanded: true,
        backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
        children: transactionList.toList());
  }

  buildTransactionList(BuildContext context, Transaction transaction) {
    return MergeSemantics(
        child: new ListTile(
      dense: true,
      title: Text(transaction.categoryName),
      subtitle: new Text("${transaction.description}\n${transaction
              .creatorUserName}'s ${transaction.accountName}"),
      isThreeLine: true,
      trailing: Text('${transaction.amount
              .toString()} ${transaction.accountCurrencySymbol}'),
      leading: CircleAvatar(
        backgroundColor: transaction.amount > 0
            ? Theme.of(context).primaryColor
            : Theme.of(context).disabledColor,
      ),
    ));
  }

  TransactionList(this.transactions);
}
