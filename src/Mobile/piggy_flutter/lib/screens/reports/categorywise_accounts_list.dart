import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/common.dart';

class CategorywiseAccountsList extends StatelessWidget {
  CategorywiseAccountsList({Key? key, required this.items, bool? visible})
      : visible = visible ?? items.isNotEmpty,
        super(key: key);

  final List<CategoryReportGroupedListItem> items;
  final DateFormat formatter = DateFormat("EEE, MMM d, ''yy");
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final List<Widget> groupedItems = [];

    groupedItems.addAll(items.map((CategoryReportGroupedListItem item) =>
        buildGroupedItemTile(context, item)));

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: groupedItems.toList(),
      ),
    );
  }

  ExpansionTile buildGroupedItemTile(
      BuildContext context, CategoryReportGroupedListItem item) {
    final Iterable<Widget> accounts = item.accounts
        .map((CategoryReportGroupedListItemAccount account) => buildAccountList(
              context,
              account,
            ));

    return ExpansionTile(
      key: PageStorageKey<String?>(item.categoryName),
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('${item.categoryName}',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontSize: 16.0, color: Theme.of(context).accentColor)),
          Row(
            children: <Widget>[
              // Chip(
              //   label: Text('${item.totalInflow.toMoney()}Rs'),
              //   backgroundColor: Colors.greenAccent.shade100,
              // ),
              Chip(
                label: Text(
                  '${item.totalAmountInDefaultCurrency.toMoney()} Rs',
                ),
                backgroundColor: Colors.red.shade100,
              )
            ],
          )
        ],
      ),
      initiallyExpanded: true,
      children: accounts.toList(),
    );
  }

  MergeSemantics buildAccountList(
      BuildContext context, CategoryReportGroupedListItemAccount account) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return MergeSemantics(
      child: ListTile(
        dense: true,
        title: Text(
          account.accountName!,
          style: textTheme.bodyText1,
        ),
        subtitle: Text(
          '${account.amountInDefaultCurrency.toMoney()}',
          style: TextStyle(
            color: PiggyAppTheme.nearlyBlue,
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
        trailing: Text(
          '${account.amount.toMoney()} ${account.currencyCode}',
        ),
      ),
    );
  }
}
