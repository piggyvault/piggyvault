import 'package:flutter/material.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:intl/intl.dart';

class RecentPage extends StatefulWidget {
  @override
  _RecentPageState createState() => new _RecentPageState();

  RecentPage({Key key}) : super(key: key);
}

class _RecentPageState extends State<RecentPage> {
  List<dynamic> transactions = [];
  TransactionService _transactionService = new TransactionService();

  @override
  void initState() {
    super.initState();
    _transactionService
        .getTransactions(new GetTransactionsInput(
            "tenant",
            null,
            new DateTime.now().add(new Duration(days: -100)).toString(),
            new DateTime.now().add(new Duration(days: 1)).toString()))
        .then((result) {
      groupTransactions(result.content['items'], 'transactionTime');
    });
  }

  void groupTransactions(List<dynamic> items, String groupBy) {
    List<dynamic> groupedItems = [];

    if (groupBy == 'transactionTime') {
      for (var i = 0; i < items.length; i++) {
        var date = DateTime.parse(items[i]['transactionTime']);
        var index = date.year * 10000 + (date.month * 100) + date.day;
        print('$date $index');

        var day = groupedItems.firstWhere((o) => o['index'] == index,
            orElse: () => null);

        if (day == null) {
          var formatter = new DateFormat("EEE, MMM d, ''yy");

          day = {
            'index': index,
            'title': formatter.format(date),
            'transactions': [],
            'totalInflow': 0,
            'totalOutflow': 0
          };

          groupedItems.add(day);
        }

        if (items[i]['amountInDefaultCurrency'] > 0) {
          day['totalInflow'] += items[i]['amountInDefaultCurrency'];
        } else {
          day['totalOutflow'] += items[i]['amountInDefaultCurrency'];
        }

        var transactions = day['transactions'] as List<dynamic>;
        transactions.add(items[i]);
      }

      print(groupedItems);
    }

    setState(() {
      transactions = groupedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.length > 0) {
      Iterable<Widget> groupedTransactionList = transactions
          .map((dynamic item) => buildGroupedTransactionTile(context, item));
      return new ListView(
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

  buildGroupedTransactionTile(BuildContext context, item) {
    var dayTransactions = item['transactions'] as List<dynamic>;
    Iterable<Widget> transactionList = dayTransactions.map(
        (dynamic transaction) => buildTransactionList(context, transaction));

   return new ExpansionTile(
      title: Text(item['title']),
      initiallyExpanded: true,
      backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
        children: transactionList.toList()
    );
  }

  buildTransactionList(BuildContext context, transaction) {
    return new MergeSemantics(
        child: new ListTile(
      dense: true,
      title: Text(transaction['category']['name']),
      subtitle: new Text(
          "${transaction['description']}\n${transaction['creatorUserName']}'s ${transaction['account']['name']}"),
      isThreeLine: true,
      trailing: Text('${transaction['amount']
              .toString()} ${transaction['account']['currency']['symbol']}'),
      leading: CircleAvatar(
        backgroundColor: transaction['amount'] > 0
            ? Theme.of(context).primaryColor
            : Theme.of(context).disabledColor,
      ),
    ));
  }
}
