import 'package:flutter/material.dart';
import 'package:piggy_flutter/ui/widgets/about_tile.dart';


class CommonDrawer extends StatelessWidget {
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
              color: Colors.red,
            ),
          ),
          new ListTile(
            title: Text(
              "Accounts",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
            leading: Icon(
              Icons.account_balance_wallet,
              color: Colors.green,
            ),
          ),
          new ListTile(
            title: Text(
              "Categories",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
            leading: Icon(
              Icons.category,
              color: Colors.cyan,
            ),
          ),
          new ListTile(
            title: Text(
              "Profile",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
            leading: Icon(
              Icons.person,
              color: Colors.blue,
            ),
          ),



          Divider(),
          new ListTile(
            title: Text(
              "Settings",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
            leading: Icon(
              Icons.settings,
              color: Colors.brown,
            ),
          ),
          Divider(),
          MyAboutTile()
        ],
      ),
    );
  }
}