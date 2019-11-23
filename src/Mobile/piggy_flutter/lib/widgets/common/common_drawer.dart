import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/accounts/accounts_bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts_state.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart' as oldBloc;
import 'package:piggy_flutter/blocs/category_bloc.dart';
import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/screens/reports/categorywise_recent_months_report_screen.dart';
import 'package:piggy_flutter/user/user.dart';
import 'package:piggy_flutter/user/user_bloc.dart';
import 'package:piggy_flutter/widgets/about_tile.dart';
import 'package:piggy_flutter/screens/home/home.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommonDrawer extends StatelessWidget {
  final menuTextStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    final CategoryBloc categoryBloc =
        oldBloc.BlocProvider.of<CategoryBloc>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          drawerHeader(),
          ListTile(
            title: Text(
              "Home",
              style: menuTextStyle,
            ),
            leading: Icon(
              Icons.home,
              color: Colors.blue,
            ),
            onTap: (() => Navigator.of(context)
                .pushReplacementNamed(UIData.dashboardRoute)),
          ),
          ListTile(
              title: Text(
                "Accounts",
                style: menuTextStyle,
              ),
              leading: Icon(
                Icons.account_balance_wallet,
                color: Colors.green,
              ),
              onTap: (() => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              startpage: StartPage.Accounts,
                            )),
                  )),
              trailing: BlocBuilder<AccountsBloc, AccountsState>(
                  builder: (context, state) {
                if (state is AccountsLoaded) {
                  return Chip(
                    backgroundColor: Colors.green,
                    label: Text(state.userAccounts.length.toString()),
                  );
                }
                return Chip(
                  label: Icon(Icons.hourglass_empty),
                );
              })),
          categoriesTile(categoryBloc),
          ListTile(
            title: Text(
              "Reports",
              style: menuTextStyle,
            ),
            leading: Icon(
              Icons.insert_chart,
              color: Colors.amber,
            ),
            onTap: (() => Navigator.of(context).pushReplacementNamed(
                CategoryWiseRecentMonthsReportScreen.routeName)),
          ),
          Divider(),
          ListTile(
            title: Text(
              "Logout",
            ),
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.red,
            ),
            onTap: (() {
              BlocProvider.of<AuthBloc>(context).add(LoggedOut());
            }),
          ),
          Divider(),
          MyAboutTile()
        ],
      ),
    );
  }

  Widget categoriesTile(CategoryBloc categoryBloc) {
    return StreamBuilder<List<Category>>(
      stream: categoryBloc.categories,
      builder: (context, snapshot) {
        return ListTile(
          title: Text(
            "Categories",
            style: menuTextStyle,
          ),
          leading: Icon(
            Icons.category,
            color: Colors.cyan,
          ),
          onTap: (() => Navigator.of(context)
              .pushReplacementNamed(UIData.categoriesRoute)),
          trailing: snapshot.hasData
              ? Chip(
                  key: ValueKey<String>(snapshot.data.length.toString()),
                  backgroundColor: Colors.cyan,
                  label: Text(snapshot.data.length.toString()),
                )
              : Chip(
                  label: Icon(Icons.hourglass_empty),
                ),
        );
      },
    );
  }

  Widget drawerHeader() {
    return BlocBuilder<UserBloc, UserState>(builder: (context, state) {
      if (state is UserLoaded) {
        return UserAccountsDrawerHeader(
          accountName: Text(
            '${state.user.name} ${state.user.surname}',
          ),
          accountEmail: Text(
            state.user.emailAddress,
          ),
          currentAccountPicture: new CircleAvatar(
//              backgroundImage: new AssetImage(UIData.pkImage),
              ),
        );
      }

      return DrawerHeader(
        child: Text('User not logged in'),
      );
    });
  }
}
