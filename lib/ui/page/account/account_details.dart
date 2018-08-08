import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/bloc/transaction_bloc.dart';
import 'package:piggy_flutter/model/account.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:piggy_flutter/ui/page/transaction/transaction_form.dart';
import 'package:piggy_flutter/ui/widgets/transaction_list.dart';
import 'package:piggy_flutter/utils/uidata.dart';

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
  final Account account;

  @override
  AccountDetailsPageState createState() => AccountDetailsPageState();

  AccountDetailsPage({Key key, this.account}) : super(key: key);
}

class AccountDetailsPageState extends State<AccountDetailsPage>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  final TransactionService _transactionService = TransactionService();
  final TransactionBloc _transactionBloc =TransactionBloc();

  void setPages() {
    // creating 6 tabs
    for (int i = 5; i >= 0; i--) {
      var page = _allPages[i];

      var startMonth = DateTime.now().month - page.monthDifferenceIndex;
      var startYear = DateTime.now().year;
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

      var startDate = DateTime(startYear, startMonth, 1);
      var endDate =
          DateTime(endYear, endMonth, 1).add(Duration(milliseconds: -1));
      var formatter = DateFormat("MMM, ''yy");

      var input = GetTransactionsInput(
          type: 'account',
          accountId: widget.account.id,
          startDate: startDate,
          endDate: endDate,
          groupBy: TransactionsGroupBy.Date);

      _transactionService.getTransactions(input).then((result) {
        page.transactions = result;
        page.title = formatter.format(startDate);
        setState(() {});
      });
    }
  }

  Decoration getIndicator() {
    return ShapeDecoration(
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

  onSyncRequired(bool isRequired){
    if(isRequired){
      print('sync required');
    }
  }



  @override
  void initState() {
    super.initState();
    _controller = TabController(
        vsync: this,
        length: _allPages.length,
        initialIndex: _allPages.length - 1);
    setPages();
    _transactionBloc.isTransactionSyncRequired.listen(onSyncRequired);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.account.name} - ${widget.account.currentBalance} ${widget.account.currencySymbol}'),
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          indicator: getIndicator(),
          tabs: _allPages.map((_Page page) {
            return Tab(text: page.title);
          }).toList(),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
//            onSelected: showMenuSelection,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: UIData.adjust_balance,
                    child: ListTile(
                      leading: Icon(Icons.account_balance),
                      title: Text(UIData.adjust_balance),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: TabBarView(
          controller: _controller,
          children: _allPages.map((_Page page) {
            return TransactionList(transactions: page.transactions);
          }).toList()),
      floatingActionButton: FloatingActionButton(
          key: ValueKey<Color>(Theme.of(context).primaryColor),
          tooltip: 'Add new transaction',
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add_circle_outline),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute<DismissDialogAction>(
                  builder: (BuildContext context) => TransactionFormPage(
                        account: widget.account,
                      ),
                  fullscreenDialog: true,
                ));
          }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
