import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:piggy_flutter/ui/widgets/transaction_list.dart';

enum TabsDemoStyle { iconsAndText, iconsOnly, textOnly }

class _Page {
  String title;
  final int monthDifferenceIndex;
  List<TransactionGroupItem> transactions;
  _Page(this.title, this.monthDifferenceIndex);
}

List<_Page> _allPages = [
  _Page('6 Months ago', 5),
  _Page('5 Months ago', 4),
  _Page('4 Months ago', 3),
  _Page('3 Months ago', 2),
  _Page('Last Month', 1),
  _Page('This Month', 0),
];

class AccountDetailsPage extends StatefulWidget {
  static const String routeName = '/account/details';

  final String title, accountId;
  final String currentBalance;

  @override
  AccountDetailsPageState createState() => new AccountDetailsPageState();

  AccountDetailsPage(this.accountId, this.title, this.currentBalance);
}

class AccountDetailsPageState extends State<AccountDetailsPage>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  bool _customIndicator = false;
  final TransactionService _transactionService = new TransactionService();

  @override
  void initState() {
    super.initState();
    _controller = new TabController(
        vsync: this,
        length: _allPages.length,
        initialIndex: _allPages.length - 1);
    setPages();
  }

  void setPages() {
    // creating 6 tabs
    for (int i = 5; i >= 0; i--) {
      var page = _allPages[i];

      var startMonth = new DateTime.now().month - page.monthDifferenceIndex;
      var startYear = new DateTime.now().year;
      if (startMonth < 0) {
        startMonth += 11;
        startYear -= 1;
      }

      var endMonth = startMonth + 1;
      var endYear = startYear;
      if (endMonth > 11) {
        endMonth -= 11;
        endYear += 1;
      }

      var startDate = new DateTime(startYear, startMonth, 1);
      var endDate = new DateTime(endYear, endMonth, 1)
          .add(new Duration(milliseconds: -1));

      print('index is ${page.monthDifferenceIndex}, $startDate - $endDate');

      var formatter = new DateFormat("MMM, ''yy");

      var input = GetTransactionsInput('account', widget.accountId,
          startDate.toString(), endDate.toString(), 'account');

      _transactionService.getTransactions(input).then((result) {
        page.transactions = result;
        page.title = formatter.format(startDate);
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Decoration getIndicator() {
    if (!_customIndicator) return const UnderlineTabIndicator();

    return new ShapeDecoration(
      shape: const StadiumBorder(
            side: const BorderSide(
              color: Colors.white24,
              width: 2.0,
            ),
          ) +
          const StadiumBorder(
            side: const BorderSide(
              color: Colors.transparent,
              width: 4.0,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        bottom: new TabBar(
          controller: _controller,
          isScrollable: true,
          indicator: getIndicator(),
          tabs: _allPages.map((_Page page) {
            return new Tab(text: page.title);
          }).toList(),
        ),
      ),
      body: new TabBarView(
          controller: _controller,
          children: _allPages.map((_Page page) {
            return new TransactionList(page.transactions);
          }).toList()),
    );
  }
}
