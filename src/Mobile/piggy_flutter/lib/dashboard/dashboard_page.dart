import 'package:flutter/material.dart';
import 'package:piggy_flutter/dashboard/index.dart';

class DashboardPage extends StatelessWidget {
  static const String routeName = "/dashboard";

  @override
  Widget build(BuildContext context) {
    var _dashboardBloc = DashboardBloc();
    return Scaffold(
      appBar: AppBar(
        // leading: Container(), // TODO: To hide back button
        elevation: 2.0,
        title: Text(
          'Dashboard',
        ),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('piggyvault.in',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14.0)),
                Icon(
                  Icons.arrow_drop_down,
                )
              ],
            ),
          )
        ],
      ),
      body: DashboardScreen(dashboardBloc: _dashboardBloc),
    );
  }
}
