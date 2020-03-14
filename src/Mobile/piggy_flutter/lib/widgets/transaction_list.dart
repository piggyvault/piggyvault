import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/transaction_detail/bloc.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/models/transaction_group_item.dart';
import 'package:piggy_flutter/screens/transaction/transaction_detail.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/common.dart';

class TransactionList extends StatelessWidget {
  TransactionList({Key key, @required this.items, this.isLoading, bool visible})
      : visible = visible ?? items.isNotEmpty,
        super(key: key);

  final List<TransactionGroupItem> items;
  final Stream<bool> isLoading;
  final DateFormat formatter = DateFormat("EEE, MMM d, ''yy");
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final List<Widget> groupedTransactionList = [];
    if (isLoading != null) {
      groupedTransactionList.add(_loadingInfo(isLoading));
    }

    groupedTransactionList.addAll(items.map((TransactionGroupItem item) =>
        buildGroupedTransactionTile(context, item)));

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: groupedTransactionList.toList(),
      ),
    );
  }

  Widget _loadingInfo(Stream<bool> isLoading) {
    return StreamBuilder<bool>(
      stream: isLoading,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return const LinearProgressIndicator();
        } else {
          return Container();
        }
      },
    );
  }

  ExpansionTile buildGroupedTransactionTile(
      BuildContext context, TransactionGroupItem item) {
    final Iterable<Widget> transactionList = item.transactions.map(
        (Transaction transaction) =>
            buildTransactionList(context, transaction, item.groupby));

    return ExpansionTile(
      key: PageStorageKey<String>(item.title),
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('${item.title}',
              style: Theme.of(context).textTheme.title.copyWith(
                  fontSize: 16.0, color: Theme.of(context).accentColor)),
          Row(
            children: <Widget>[
              Chip(
                label: Text('${item.totalInflow.toMoney()}Rs'),
                backgroundColor: Colors.greenAccent.shade100,
              ),
              Chip(
                label: Text(
                  '${item.totalOutflow.toMoney()}Rs',
                ),
                backgroundColor: Colors.red.shade100,
              )
            ],
          )
        ],
      ),
      initiallyExpanded: true,
      children: transactionList.toList(),
    );
  }

  MergeSemantics buildTransactionList(BuildContext context,
      Transaction transaction, TransactionsGroupBy groupBy) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return MergeSemantics(
      child: ListTile(
        dense: true,
        leading: Container(
          decoration: BoxDecoration(
            color: transaction.amount > 0
                ? PiggyAppTheme.nearlyDarkBlue
                : PiggyAppTheme.grey,
            gradient: transaction.amount > 0
                ? LinearGradient(
                    colors: [Colors.green, Colors.green[100]],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : LinearGradient(colors: [
                    Colors.red,
                    Colors.red[100],
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: transaction.amount > 0
                ? Icon(
                    Icons.radio_button_unchecked,
                    color: PiggyAppTheme.white,
                    size: 32,
                  )
                : Icon(
                    Icons.radio_button_unchecked,
                    color: PiggyAppTheme.white,
                    size: 32,
                  ),
          ),
        ),
        title: Text(
          groupBy == TransactionsGroupBy.Date
              ? transaction.categoryName
              : formatter.format(DateTime.parse(transaction.transactionTime)),
          style: textTheme.body2,
        ),
        subtitle: Text(
          "${transaction.description}\n${transaction.creatorUserName}'s ${transaction.accountName}",
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '${transaction.amount.toMoney()} ${transaction.accountCurrencySymbol}',
            ),
            Text(
              '${transaction.balance.toMoney()} ${transaction.accountCurrencySymbol}',
              style: TextStyle(
                color: PiggyAppTheme.nearlyBlue,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            )
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => TransactionDetailPage(
                transactionDetailBloc:
                    BlocProvider.of<TransactionDetailBloc>(context),
                transaction: transaction,
              ),
              fullscreenDialog: true,
            ),
          );
        },
      ),
    );
  }
}
