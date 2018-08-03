import 'package:flutter/material.dart';
import 'package:piggy_flutter/model/transaction.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';
import 'package:piggy_flutter/ui/page/transaction/transaction_detail.dart';
import 'package:piggy_flutter/ui/widgets/common/message_placeholder.dart';

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
        return MessagePlaceholder();
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

  TransactionList({Key key, this.transactions}) : super(key: key);
}
