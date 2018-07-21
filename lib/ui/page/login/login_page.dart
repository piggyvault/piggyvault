import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:piggy_flutter/ui/page/home/home.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/main.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController tenantNameController =
      new TextEditingController();
  final TextEditingController userNameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authCheck();
  }

  void authCheck() async {
    print('auth check');
    final prefs = await SharedPreferences.getInstance();

    var token = prefs.getString(UIData.authToken);

    print('token is $token');

    if (token != null && token.length > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: loginBody(context),
      ),
    );
  }

  loginBody(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[loginHeader(), loginFields(context)],
      );

  loginHeader() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlutterLogo(
            colors: Colors.green,
            size: 80.0,
          ),
          SizedBox(
            height: 30.0,
          ),
          Text(
            "Welcome to ${UIData.appName}",
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            "Sign in to continue",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );

  loginFields(BuildContext context) => Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
              child: TextField(
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: "Enter your family name",
                  labelText: "Family",
                ),
                controller: tenantNameController,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
              child: TextField(
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: "Enter your username",
                  labelText: "Username",
                ),
                controller: userNameController,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
              child: TextField(
                maxLines: 1,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  labelText: "Password",
                ),
                controller: passwordController,
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
              width: double.infinity,
              child: RaisedButton(
                padding: EdgeInsets.all(12.0),
                shape: StadiumBorder(),
                child: Text(
                  "SIGN IN",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.green,
                onPressed: () {
                  login(context);
                },
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
//        Text(
//          "SIGN UP FOR AN ACCOUNT",
//          style: TextStyle(color: Colors.grey),
//        ),
          ],
        ),
      );

  login(BuildContext context) async {
//    print('family is ${tenantNameController.text}');

    var url = 'http://piggyvault.in/api/Account/Authenticate';
    var input = json.encode({
      "tenancyName": tenantNameController.text,
      "usernameOrEmailAddress": userNameController.text,
      "password": passwordController.text
    });
//print('input is $input');
    http.post(url, body: input, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    }).then((response) async {
      var res = json.decode(response.body);
      if (res["success"]) {
        final prefs = await SharedPreferences.getInstance();
// set value
        await prefs.setString(UIData.authToken, res["result"]);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage()),
        );
      } else {}
//          print(res);
//          print(res["success"]);
//          print(res["result"]);
//      print("Response status: ${response.statusCode}");
//      print("Response body: ${response.body}");
    });
  }
}
