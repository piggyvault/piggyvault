import 'package:flutter/material.dart';
import 'package:piggy_flutter/services/transaction_service.dart';

class SummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => new _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  TransactionService _transactionService = new TransactionService();
  double tenantNetWorth,
      userNetWorth,
      tenantIncome,
      userIncome,
      userExprense,
      tenantExpense,
      tenantSaved,
      userSaved;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _transactionService.getTransactionSummary("month").then((res) {
      setState(() {
        var result = res.content;
        userNetWorth = result['userNetWorth'];
        tenantNetWorth = result['tenantNetWorth'];
        tenantIncome = result['tenantIncome'];
        userIncome = result['userIncome'];
        userExprense = result['userExprense'];
        tenantExpense = result['tenantExpense'];
        tenantSaved = result['tenantSaved'];
        userSaved = result['userSaved'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
//          LoginBackground(
//            showIcon: false,
//          ),
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
//          appBarColumn(context),
//          SizedBox(
//            height: deviceSize.height * 0.01,
//          ),
//          searchCard(),
//          SizedBox(
//            height: deviceSize.height * 0.01,
//          ),
//          actionMenuCard(),
//          SizedBox(
//            height: deviceSize.height * 0.01,
//          ),
                balanceCard('Net Worth', userNetWorth, tenantNetWorth),
                balanceCard('Monthly Income', userIncome, tenantIncome),
                balanceCard('Monthly Expense', userExprense, tenantExpense),
                balanceCard('Monthly Savings', userSaved, tenantSaved),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget balanceCard(String title, double userValue, double tenantValue) =>
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
                    Text(
                      title,
//                  style: TextStyle(fontFamily: UIData.ralewayFont),
                    ),
                    Material(
                      color: Colors.black,
                      shape: StadiumBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Family: ${tenantValue.toString()}",
                          style: TextStyle(
                            color: Colors.white,
//                          fontFamily: UIData.ralewayFont
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Text(
                  "₹ ${userValue.toString()}",
                  style: TextStyle(
//                  fontFamily: UIData.ralewayFont,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                      fontSize: 25.0),
                ),
              ],
            ),
          ),
        ),
      );
}
