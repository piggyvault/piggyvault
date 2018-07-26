import 'package:flutter/material.dart';
import 'package:piggy_flutter/ui/page/category/category_list.dart';
import 'package:piggy_flutter/ui/page/login/login_page.dart';
import 'package:piggy_flutter/utils/uidata.dart';

//import 'package:shared_preferences/shared_preferences.dart';
import 'package:piggy_flutter/ui/page/home/home.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Piggy',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new LoginPage(),
//      home: new MyHomePage(title: 'Dashboard'),
      routes: <String, WidgetBuilder>{
        UIData.loginRoute: (BuildContext context) => LoginPage(),
        UIData.dashboardRoute: (BuildContext context) => HomePage(),
        UIData.categoryRoute: (BuildContext context) => CategoryListPage(),
      },
    );
  }
}
