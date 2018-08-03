import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/model/transaction.dart';
import 'package:piggy_flutter/ui/page/transaction/transaction_form.dart';

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;
  final formatter = new DateFormat("EEE, MMM d, ''yy");

  TransactionDetailPage({Key key, this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: Text('Transaction Details'),
          actions: <Widget>[
            new IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) => new TransactionFormPage(
                          transaction: transaction,
                          title: 'Edit Transaction',
                        ),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
            new IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) => new TransactionFormPage(
                          transaction: transaction,
                          title: 'Copy Transaction',
                          isCopy: true,
                        ),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
            new IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {},
            ),
          ],
        ),
        body: new Card(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.category),
                title: new Text(transaction.categoryName),
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: new Text('${transaction.amount.toString()} ${transaction
                    .accountCurrencySymbol}'),
              ),
              ListTile(
                leading: const Icon(Icons.event_note),
                subtitle: new Text(transaction.description),
                isThreeLine: true,
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: new Text('${formatter.format(
                    DateTime.parse(transaction.transactionTime))}'),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: new Text(transaction.accountName),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: new Text(transaction.creatorUserName),
              ),
//          new ButtonTheme.bar(
//            // make buttons use the appropriate styles for cards
//            child: new ButtonBar(
//              children: <Widget>[
//                new FlatButton(
//                  child: const Text('BUY TICKETS'),
//                  onPressed: () {
//                    /* ... */
//                  },
//                ),
//                new FlatButton(
//                  child: const Text('LISTEN'),
//                  onPressed: () {
//                    /* ... */
//                  },
//                ),
//              ],
//            ),
//          ),
            ],
          ),
        ));
  }
}
