import 'package:flutter/material.dart';
import 'package:piggy_flutter/services/transaction_service.dart';

class SummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => new _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  TransactionService _transactionService = new TransactionService();
  bool isLoading = true;
  double tenantNetWorth = 0.0,
      userNetWorth = 0.0,
      tenantIncome = 0.0,
      userIncome = 0.0,
      userExprense = 0.0,
      tenantExpense = 0.0,
      tenantSaved = 0.0,
      userSaved = 0.0;

  @override
  void initState() {
    super.initState();

    _transactionService.getTransactionSummary("month").then((res) {
      setState(() {
        var result = res.content;
        userNetWorth = result['userNetWorth'];
//        userNetWorth = null;
        tenantNetWorth = result['tenantNetWorth'];
        tenantIncome = result['tenantIncome'];
        userIncome = result['userIncome'];
        userExprense = result['userExprense'];
        tenantExpense = result['tenantExpense'];
        tenantSaved = result['tenantSaved'];
        userSaved = result['userSaved'];
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                //
                isLoading ? LinearProgressIndicator() : null,
                balanceCard(
                    'Net Worth', userNetWorth, tenantNetWorth, Colors.green),
                balanceCard('Monthly Income', userIncome, tenantIncome,
                    Theme.of(context).primaryColor),
                balanceCard('Monthly Expense', userExprense, tenantExpense,
                    Colors.redAccent),
                balanceCard('Monthly Savings', userSaved, tenantSaved,
                    Colors.lightGreen),
              ].where((child) => child != null).toList(),
            ),
          ),
        ],
      ),
    );
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
