import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/bloc/transaction_bloc.dart';
import 'package:piggy_flutter/model/transaction.dart';
import 'package:piggy_flutter/model/transaction_comment.dart';
import 'package:piggy_flutter/providers/transaction_provider.dart';
import 'package:piggy_flutter/ui/page/transaction/transaction_form.dart';

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;
  final formatter = DateFormat("EEE, MMM d, ''yy");
  final commentTimeFormatter = DateFormat("h:mm a, EEE, MMM d, ''yy");

  TransactionDetailPage({Key key, this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TransactionBloc transactionBloc = TransactionProvider.of(context);
    transactionBloc.transactionCommentsRefresh(transaction.id);
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: new ListView(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        children: <Widget>[
          transactionDetails(),
          ListTile(
            title: Text(
              'Comments',
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          transactionComments(transactionBloc),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => TransactionFormPage(
                          transaction: transaction,
                          title: 'Edit Transaction',
                        ),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => TransactionFormPage(
                          transaction: transaction,
                          title: 'Copy Transaction',
                          isCopy: true,
                        ),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionComments(TransactionBloc transactionBloc) {
    return StreamBuilder<List<TransactionComment>>(
        stream: transactionBloc.transactionComments,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Card(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data.map((comment) {
                    return ListTile(
                      leading: const CircleAvatar(),
                      title: Text(comment.creatorUserName),
                      subtitle: Text(comment.content),
                      trailing: Text('${commentTimeFormatter.format(
                  DateTime.parse(comment.creationTime))}'),
                    );
                  }).toList()),
            );
          } else {
            return LinearProgressIndicator();
          }
        });
  }

  Widget transactionDetails() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(transaction.categoryName),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text('${transaction.amount.toString()} ${transaction
                  .accountCurrencySymbol}'),
          ),
          ListTile(
            leading: const Icon(Icons.event_note),
            subtitle: Text(transaction.description),
            isThreeLine: true,
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text('${formatter.format(
                  DateTime.parse(transaction.transactionTime))}'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: Text(transaction.accountName),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(transaction.creatorUserName),
          ),
        ],
      ),
    );
  }
}
