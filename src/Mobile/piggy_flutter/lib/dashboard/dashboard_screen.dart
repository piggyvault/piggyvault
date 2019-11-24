import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:piggy_flutter/blocs/recent_transactions/recent_transactions_bloc.dart';
import 'package:piggy_flutter/blocs/recent_transactions/recent_transactions_state.dart';
import 'package:piggy_flutter/blocs/transaction_summary/transaction_summary_bloc.dart';
import 'package:piggy_flutter/blocs/transaction_summary/transaction_summary_state.dart';
import 'package:piggy_flutter/dashboard/index.dart';
import 'package:piggy_flutter/screens/reports/categorywise_recent_months_report_screen.dart';
import 'package:piggy_flutter/screens/transaction/transaction_form.dart';
import 'package:piggy_flutter/utils/common.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    Key key,
    @required DashboardBloc dashboardBloc,
  })  : _dashboardBloc = dashboardBloc,
        super(key: key);

  final DashboardBloc _dashboardBloc;

  @override
  DashboardScreenState createState() {
    return DashboardScreenState(_dashboardBloc);
  }
}

class DashboardScreenState extends State<DashboardScreen> {
  final DashboardBloc _dashboardBloc;
  DashboardScreenState(this._dashboardBloc);

  @override
  void initState() {
    super.initState();
    this._load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final List<List<double>> charts = [
    [
      0.0,
      0.3,
      0.7,
      0.6,
      0.55,
      0.8,
      1.2,
      1.3,
      1.35,
      0.9,
      1.5,
      1.7,
      1.8,
      1.7,
      1.2,
      0.8,
      1.9,
      2.0,
      2.2,
      1.9,
      2.2,
      2.1,
      2.0,
      2.3,
      2.4,
      2.45,
      2.6,
      3.6,
      2.6,
      2.7,
      2.9,
      2.8,
      3.4
    ],
    [
      0.0,
      0.3,
      0.7,
      0.6,
      0.55,
      0.8,
      1.2,
      1.3,
      1.35,
      0.9,
      1.5,
      1.7,
      1.8,
      1.7,
      1.2,
      0.8,
      1.9,
      2.0,
      2.2,
      1.9,
      2.2,
      2.1,
      2.0,
      2.3,
      2.4,
      2.45,
      2.6,
      3.6,
      2.6,
      2.7,
      2.9,
      2.8,
      3.4,
      0.0,
      0.3,
      0.7,
      0.6,
      0.55,
      0.8,
      1.2,
      1.3,
      1.35,
      0.9,
      1.5,
      1.7,
      1.8,
      1.7,
      1.2,
      0.8,
      1.9,
      2.0,
      2.2,
      1.9,
      2.2,
      2.1,
      2.0,
      2.3,
      2.4,
      2.45,
      2.6,
      3.6,
      2.6,
      2.7,
      2.9,
      2.8,
      3.4,
    ],
    [
      0.0,
      0.3,
      0.7,
      0.6,
      0.55,
      0.8,
      1.2,
      1.3,
      1.35,
      0.9,
      1.5,
      1.7,
      1.8,
      1.7,
      1.2,
      0.8,
      1.9,
      2.0,
      2.2,
      1.9,
      2.2,
      2.1,
      2.0,
      2.3,
      2.4,
      2.45,
      2.6,
      3.6,
      2.6,
      2.7,
      2.9,
      2.8,
      3.4,
      0.0,
      0.3,
      0.7,
      0.6,
      0.55,
      0.8,
      1.2,
      1.3,
      1.35,
      0.9,
      1.5,
      1.7,
      1.8,
      1.7,
      1.2,
      0.8,
      1.9,
      2.0,
      2.2,
      1.9,
      2.2,
      2.1,
      2.0,
      2.3,
      2.4,
      2.45,
      2.6,
      3.6,
      2.6,
      2.7,
      2.9,
      2.8,
      3.4,
      0.0,
      0.3,
      0.7,
      0.6,
      0.55,
      0.8,
      1.2,
      1.3,
      1.35,
      0.9,
      1.5,
      1.7,
      1.8,
      1.7,
      1.2,
      0.8,
      1.9,
      2.0,
      2.2,
      1.9,
      2.2,
      2.1,
      2.0,
      2.3,
      2.4,
      2.45,
      2.6,
      3.6,
      2.6,
      2.7,
      2.9,
      2.8,
      3.4
    ]
  ];

  static final List<String> chartDropdownItems = [
    'Last 7 days',
    'Last month',
    'Last year'
  ];
  String actualDropdown = chartDropdownItems[0];
  int actualChart = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
        bloc: widget._dashboardBloc,
        builder: (
          BuildContext context,
          DashboardState currentState,
        ) {
          if (currentState is UnDashboardState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (currentState is ErrorDashboardState) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(currentState.errorMessage ?? 'Error'),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: RaisedButton(
                    color: Colors.blue,
                    child: Text("reload"),
                    onPressed: () => this._load(),
                  ),
                ),
              ],
            ));
          }
          return StaggeredGridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: <Widget>[
              _balanceTile(),
              _transactionsCountTile(),
              _buildTile(
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Material(
                              color: Colors.amber,
                              shape: CircleBorder(),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Icon(Icons.multiline_chart,
                                    color: Colors.white, size: 30.0),
                              )),
                          Padding(padding: EdgeInsets.only(bottom: 16.0)),
                          Text('Reports',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24.0)),
                          Text('Categorywise Recent',
                              style: TextStyle(color: Colors.black45)),
                        ]),
                  ),
                  onTap: (() => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          CategoryWiseRecentMonthsReportScreen())))),
              _buildTile(
                Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Expense',
                                    style: TextStyle(color: Colors.green)),
                                Text('\$16K',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 34.0)),
                              ],
                            ),
                            DropdownButton(
                                isDense: true,
                                value: actualDropdown,
                                onChanged: (String value) => setState(() {
                                      actualDropdown = value;
                                      actualChart = chartDropdownItems
                                          .indexOf(value); // Refresh the chart
                                    }),
                                items: chartDropdownItems.map((String title) {
                                  return DropdownMenuItem(
                                    value: title,
                                    child: Text(title,
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14.0)),
                                  );
                                }).toList())
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 4.0)),
                        Sparkline(
                          data: charts[actualChart],
                          lineWidth: 5.0,
                          lineColor: Colors.greenAccent,
                        )
                      ],
                    )),
              ),
              _lastTransactionTile()
            ],
            staggeredTiles: [
              StaggeredTile.extent(2, 110.0),
              StaggeredTile.extent(1, 180.0),
              StaggeredTile.extent(1, 180.0),
              StaggeredTile.extent(2, 220.0),
              StaggeredTile.extent(2, 110.0),
            ],
          );
        });
  }

  void _load([bool isError = false]) {
    widget._dashboardBloc.add(UnDashboardEvent());
    widget._dashboardBloc.add(LoadDashboardEvent(isError));
  }

  Widget _transactionsCountTile() {
    return _buildTile(Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
                color: Colors.teal,
                shape: CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(Icons.local_atm, color: Colors.white, size: 30.0),
                )),
            Padding(padding: EdgeInsets.only(bottom: 16.0)),
            BlocBuilder<TransactionSummaryBloc, TransactionSummaryState>(
              builder: (context, state) {
                if (state is TransactionSummaryLoaded) {
                  return Text(
                      '${state.summary.totalFamilyTransactionsCount.toString()}',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 24.0));
                } else if (state is TransactionSummaryLoading) {
                  return CircularProgressIndicator();
                }

                return Text('---');
              },
            ),
            Text('Transactions', style: TextStyle(color: Colors.black45)),
          ]),
    ));
  }

  Widget _balanceTile() {
    return _buildTile(
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Balance', style: TextStyle(color: Colors.blueAccent)),
                  BlocBuilder<TransactionSummaryBloc, TransactionSummaryState>(
                    builder: (context, state) {
                      if (state is TransactionSummaryLoaded) {
                        return Text(
                            '₹ ${state.summary.userNetWorth.toString()}',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 34.0));
                      } else if (state is TransactionSummaryLoading) {
                        return CircularProgressIndicator();
                      }

                      return Text('---');
                    },
                  )
                ],
              ),
              Material(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(24.0),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:
                        Icon(Icons.timeline, color: Colors.white, size: 30.0),
                  )))
            ]),
      ),
    );
  }

  Widget _lastTransactionTile() {
    return _buildTile(
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Last Transaction On',
                      style: TextStyle(color: Colors.redAccent)),
                  BlocBuilder<RecentTransactionsBloc, RecentTransactionsState>(
                      builder: (context, state) {
                    if (state is RecentTransactionsLoaded) {
                      return Text(state.latestTransactionDate,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 30.0));
                    }

                    if (state is RecentTransactionsLoading) {
                      return CircularProgressIndicator();
                    }

                    return Text('Data Not Available');
                  })
                ],
              ),
              Material(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(24.0),
                  child: Center(
                      child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(Icons.add, color: Colors.white, size: 30.0),
                  )))
            ]),
      ),
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute<DismissDialogAction>(
              builder: (_) => TransactionFormPage(), fullscreenDialog: true)),
    );
  }

  Widget _buildTile(Widget child, {Function() onTap}) {
    return Material(
        elevation: 14.0,
        borderRadius: BorderRadius.circular(12.0),
        shadowColor: Color(0x802196F3),
        child: InkWell(
            onTap: onTap != null
                ? () => onTap()
                : () {
                    print('Not set yet');
                  },
            child: child));
  }
}
