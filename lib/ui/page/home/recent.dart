import 'package:flutter/material.dart';
import 'package:piggy_flutter/services/transaction_service.dart';

class RecentPage extends StatefulWidget {
  @override
  _RecentPageState createState() => new _RecentPageState();
}

class _RecentPageState extends State<RecentPage> {
  List<dynamic> recentTransactions = [];
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
      setState(() {
        recentTransactions = result.content['items'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        itemCount: recentTransactions.length,
        padding: new EdgeInsets.symmetric(vertical: 4.0),
        itemBuilder: (BuildContext context, int position) {
          return new ListTile(
            title: Text(recentTransactions[position]['category']['name']),
            subtitle: new Text(
                "${recentTransactions[position]['description']}\n${recentTransactions[position]['creatorUserName']}'s ${recentTransactions[position]['account']['name']} on ${recentTransactions[position]['transactionTime']}"),
            isThreeLine: true,
            trailing: Text('${recentTransactions[position]['amount']
                .toString()} ${recentTransactions[position]['account']['currency']['symbol']}'),
            leading: CircleAvatar(
              backgroundColor: recentTransactions[position]['amount'] > 0
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
            ),
          );
        });
  }
}
