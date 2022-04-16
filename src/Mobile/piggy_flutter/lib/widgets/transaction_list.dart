// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/transaction_detail/bloc.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/models/transaction_group_item.dart';
import 'package:piggy_flutter/screens/transaction/transaction_detail.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/common.dart';

class TransactionList extends StatelessWidget {
  TransactionList(
      {Key? key, required this.items, this.isLoading, bool? visible})
      : visible = visible ?? items.isNotEmpty,
        super(key: key);

  final List<TransactionGroupItem> items;
  final Stream<bool>? isLoading;
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

  Widget _loadingInfo(Stream<bool>? isLoading) {
    return StreamBuilder<bool>(
      stream: isLoading,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData && snapshot.data!) {
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
      key: PageStorageKey<String?>(item.title),
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('${item.title}',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontSize: 16.0, color: Theme.of(context).accentColor)),
          Row(
            children: <Widget>[
              Chip(
                backgroundColor: PiggyAppTheme.incomeBackground,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20))),
                label: Text(
                  '${item.totalInflow.toMoney()}Rs',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: PiggyAppTheme.income,
                  ),
                ),
              ),
              Chip(
                backgroundColor: PiggyAppTheme.expenseBackground,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                label: Text(
                  '${item.totalOutflow.toMoney()}Rs',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: PiggyAppTheme.expense,
                  ),
                ),
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
      Transaction transaction, TransactionsGroupBy? groupBy) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return MergeSemantics(
      child: ListTile(
        dense: true,
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: NeumorphicIcon(
            deserializeIcon(Map<String, dynamic>.from(
                json.decode(transaction.categoryIcon!)))!,
            size: 24,
            style: NeumorphicStyle(
              shape: NeumorphicShape.convex,
              surfaceIntensity: 1.0,
              color: transaction.amount! > 0
                  ? PiggyAppTheme.income
                  : PiggyAppTheme.expense,
            ),
          ),
        ),
        title: Text(
          groupBy == TransactionsGroupBy.Date
              ? transaction.categoryName!
              : formatter.format(DateTime.parse(transaction.transactionTime!)),
          style: textTheme.bodyText1,
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
