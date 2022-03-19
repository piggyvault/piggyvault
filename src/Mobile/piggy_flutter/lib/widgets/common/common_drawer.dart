import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/accounts/accounts_bloc.dart';
import 'package:piggy_flutter/blocs/accounts/accounts_state.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/blocs/categories/categories_bloc.dart';
import 'package:piggy_flutter/blocs/categories/categories_state.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/screens/category/category_list.dart';
import 'package:piggy_flutter/screens/home/home_screen.dart';
import 'package:piggy_flutter/screens/reports/reports_screen.dart';
import 'package:piggy_flutter/screens/settings/settings_screen.dart';
import 'package:piggy_flutter/widgets/about_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommonDrawer extends StatelessWidget {
  final TextStyle menuTextStyle =
      const TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0);
  final AnimationController? animationController;

  const CommonDrawer({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                .push(MaterialPageRoute(builder: (context) => HomeScreen()))),
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
            onTap: (() => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      startpage: StartPage.Accounts,
                    ),
                  ),
                )),
            trailing: BlocBuilder<AccountsBloc, AccountsState>(
                builder: (context, state) {
              if (state is AccountsLoaded) {
                return Chip(
                  backgroundColor: Colors.green,
                  label: Text(state.userAccounts!.length.toString()),
                );
              }
              return Chip(
                label: Icon(Icons.hourglass_empty),
              );
            }),
          ),
          categoriesTile(context),
          ListTile(
            title: Text(
              'Reports',
              style: menuTextStyle,
            ),
            leading: Icon(
              Icons.insert_chart,
              color: Colors.amber,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => ReportsScreen(
                  animationController: animationController,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(
              "Settings",
              style: menuTextStyle,
            ),
            leading: Icon(Icons.settings, color: Colors.brown),
            onTap: (() => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                        animationController: animationController),
                  ),
                )),
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
              Navigator.popUntil(context, (ModalRoute.withName('/')));
              BlocProvider.of<AuthBloc>(context).add(LoggedOut());
            }),
          ),
          Divider(),
          MyAboutTile()
        ],
      ),
    );
  }

  Widget categoriesTile(BuildContext context) {
    return ListTile(
      title: Text(
        "Categories",
        style: menuTextStyle,
      ),
      leading: Icon(
        Icons.category,
        color: Colors.cyan,
      ),
      onTap: (() => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CategoryListPage(
                animationController: animationController,
              ),
            ),
          )),
      trailing: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
        if (state is CategoriesLoaded) {
          return Chip(
            backgroundColor: Colors.cyan,
            label: Text(state.categories.length.toString()),
          );
        }
        return Chip(
          label: Icon(Icons.hourglass_empty),
        );
      }),
    );
  }

  Widget drawerHeader() {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthAuthenticated) {
        return UserAccountsDrawerHeader(
          accountName: Text(
            '${state.user!.name} ${state.user!.surname}',
          ),
          accountEmail: Text(
            state.user!.emailAddress!,
          ),
          currentAccountPicture: CircleAvatar(
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
