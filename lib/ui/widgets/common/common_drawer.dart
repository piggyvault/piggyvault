import 'package:flutter/material.dart';
import 'package:piggy_flutter/services/auth_service.dart';
import 'package:piggy_flutter/ui/page/category/category_list.dart';
import 'package:piggy_flutter/ui/page/home/home.dart';
import 'package:piggy_flutter/ui/page/login/login_page.dart';
import 'package:piggy_flutter/ui/widgets/about_tile.dart';

class CommonDrawer extends StatelessWidget {
  final AuthService _authService = new AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              "Abhith Rajan",
            ),
            accountEmail: Text(
              "xxx-xxx.com",
            ),
            currentAccountPicture: new CircleAvatar(
//              backgroundImage: new AssetImage(UIData.pkImage),
                ),
          ),
          new ListTile(
            title: Text(
              "Home",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
            leading: Icon(
              Icons.home,
              color: Colors.blue,
            ),
            onTap: (() => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                )),
          ),
//          new ListTile(
//            title: Text(
//              "Accounts",
//              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
//            ),
//            leading: Icon(
//              Icons.account_balance_wallet,
//              color: Colors.green,
//            ),
//          ),
          new ListTile(
            title: Text(
              "Categories",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
            leading: Icon(
              Icons.category,
              color: Colors.cyan,
            ),
            onTap: (() => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryListPage()),
                )),
          ),
          Divider(),
          new ListTile(
            title: Text(
              "Logout",
            ),
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.red,
            ),
            onTap: (() {
              _authService.onLogout().then((done) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  ));
            }),
          ),
          Divider(),
          MyAboutTile()
        ],
      ),
    );
  }
}
