import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/models/transaction_group_item.dart';
import 'package:piggy_flutter/ui/page/transaction/transaction_detail.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionGroupItem> items;
  final Stream<bool> isLoading;
  final DateFormat formatter = DateFormat("EEE, MMM d, ''yy");
  final bool visible;

  TransactionList({Key key, @required this.items, this.isLoading, bool visible})
      : this.visible = visible ?? items.isNotEmpty,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> groupedTransactionList = [];
    if (isLoading != null) {
      groupedTransactionList.add(_loadingInfo(isLoading));
    }

    groupedTransactionList.addAll(
        items.map((item) => buildGroupedTransactionTile(context, item)));

    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: ListView(
        children: groupedTransactionList.toList(),
      ),
    );
  }

  Widget _loadingInfo(Stream<bool> isLoading) {
    return StreamBuilder<bool>(
      stream: isLoading,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return LinearProgressIndicator();
        } else {
          return Container();
        }
      },
    );
  }

  buildGroupedTransactionTile(BuildContext context, TransactionGroupItem item) {
    Iterable<Widget> transactionList = item.transactions.map((transaction) =>
        buildTransactionList(context, transaction, item.groupby));

    return ExpansionTile(
        key: PageStorageKey(item.title),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('${item.title}'),
            Row(
              children: <Widget>[
                Chip(
                  label: Text('${item.totalInflow.toStringAsFixed(2)}Rs'),
                  backgroundColor: Colors.greenAccent.shade100,
                ),
                Chip(
                  label: Text(
                    '${item.totalOutflow.toStringAsFixed(2)}Rs',
                  ),
                  backgroundColor: Colors.red.shade100,
                )
              ],
            )
          ],
        ),
        initiallyExpanded: true,
        backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
        children: transactionList.toList());
  }

  buildTransactionList(BuildContext context, Transaction transaction,
      TransactionsGroupBy groupBy) {
    return MergeSemantics(
      child: new ListTile(
          dense: true,
          title: Text(groupBy == TransactionsGroupBy.Date
              ? transaction.categoryName
              : formatter.format(DateTime.parse(transaction.transactionTime))),
          subtitle: new Text("${transaction.description}\n${transaction
              .creatorUserName}'s ${transaction.accountName}"),
          isThreeLine: true,
          trailing: Text('${transaction.amount
              .toString()} ${transaction.accountCurrencySymbol}'),
          leading: CircleAvatar(
            child: Text(
              groupBy == TransactionsGroupBy.Category
                  ? DateTime.parse(transaction.transactionTime).day.toString()
                  : transaction.categoryName[0],
              style: TextStyle(
                  color: transaction.amount > 0 ? Colors.white : Colors.black),
            ),
            backgroundColor: transaction.amount > 0
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor,
          ),
          onTap: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (BuildContext context) => new TransactionDetailPage(
                        transaction: transaction,
                      ),
                  fullscreenDialog: true,
                ));
          }),
    );
  }
}
