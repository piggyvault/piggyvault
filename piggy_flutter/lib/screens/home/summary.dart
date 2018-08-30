import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/blocs/transaction_bloc.dart';
import 'package:piggy_flutter/models/transaction_summary.dart';

class SummaryPage extends StatelessWidget {
  SummaryPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final TransactionBloc transactionBloc =
        BlocProvider.of<TransactionBloc>(context);
    return Scaffold(
        appBar: new AppBar(
          title: Text('Summary'),
        ),
        body: _buildBody(transactionBloc));
  }

  Widget _buildBody(TransactionBloc transactionBloc) =>
      StreamBuilder<TransactionSummary>(
          stream: transactionBloc.transactionSummary,
          initialData: null,
          builder: (context, snapshot) =>
              SummaryPageWidget(snapshot.hasData ? snapshot.data : null));
}

class SummaryPageWidget extends StatelessWidget {
  final TransactionSummary transactionSummary;

  @override
  Widget build(BuildContext context) {
    if (transactionSummary == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                balanceCard('Net Worth', transactionSummary.userNetWorth,
                    transactionSummary.tenantNetWorth, Colors.green),
                balanceCard(
                    'Monthly Income',
                    transactionSummary.userIncome,
                    transactionSummary.tenantIncome,
                    Theme.of(context).primaryColor),
                balanceCard('Monthly Expense', transactionSummary.userExpense,
                    transactionSummary.tenantExpense, Colors.redAccent),
                balanceCard('Monthly Savings', transactionSummary.userSaved,
                    transactionSummary.tenantSaved, Colors.lightGreen),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget balanceCard(
          String title, double userValue, double tenantValue, textColor) =>
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(title),
                    Material(
                      color: Colors.black,
                      shape: StadiumBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Family: ${tenantValue.toString()}",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Text(
                  "₹ ${userValue.toString()}",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      fontSize: 25.0),
                ),
              ],
            ),
          ),
        ),
      );

  SummaryPageWidget(this.transactionSummary);
}
