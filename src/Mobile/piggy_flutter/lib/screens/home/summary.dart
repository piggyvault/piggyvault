import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/transaction_summary/transaction_summary.dart';

class SummaryPage extends StatelessWidget {
  SummaryPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: Text('Summary'),
        ),
        body: BlocBuilder<TransactionSummaryBloc, TransactionSummaryState>(
            builder: (context, state) {
          if (state is TransactionSummaryLoaded) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      balanceCard('Net Worth', state.summary.userNetWorth,
                          state.summary.tenantNetWorth, Colors.green),
                      balanceCard(
                          'Monthly Income',
                          state.summary.userIncome,
                          state.summary.tenantIncome,
                          Theme.of(context).accentColor),
                      balanceCard('Monthly Expense', state.summary.userExpense,
                          state.summary.tenantExpense, Colors.redAccent),
                      balanceCard('Monthly Savings', state.summary.userSaved,
                          state.summary.tenantSaved, Colors.lightGreen),
                    ],
                  ),
                ),
              ],
            );
          }

          if (state is TransactionSummaryLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
            child: Text('---'),
          );
        }));
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
}
