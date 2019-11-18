import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piggy_flutter/screens/home/home.dart';
import 'package:piggy_flutter/screens/intro_views/intro_views.dart';
import 'package:piggy_flutter/screens/login/login_bloc.dart';
import 'package:piggy_flutter/utils/api_subscription.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/widgets/primary_color_override.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  LoginBloc _bloc;
  StreamSubscription _apiSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = LoginBloc();

    _apiSubscription = apiSubscription(
        stream: _bloc.state, context: context, key: _scaffoldKey);
    authCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: loginBody(),
      ),
    );
  }

  @override
  dispose() {
    _bloc?.dispose();
    _apiSubscription?.cancel();
    super.dispose();
  }

  void authCheck() async {
    final prefs = await SharedPreferences.getInstance();

    var token = prefs.getString(UIData.authToken);
    var firstAccess = prefs.getBool(UIData.firstAccess) ?? true;

    if (token != null && token.length > 0 && !firstAccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            isInitialLoading: true,
          ),
        ),
      );
    } else {
      if (firstAccess)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => IntroViews(),
          ),
        );
    }
  }

  final logo = Hero(
    tag: 'hero',
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 48.0,
      child: Image.asset('graphics/logo.png'),
    ),
  );

  loginBody() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[loginHeader(), loginFields()],
      );

  loginHeader() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          logo,
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

  loginFields() => Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            familyField(),
            usernameField(),
            passwordField(),
            SizedBox(
              height: 30.0,
            ),
            submitButton(),
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

  Widget familyField() {
    return StreamBuilder(
      stream: _bloc.tenancyName,
      builder: (context, snapshot) {
        return PrimaryColorOverride(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
            child: TextField(
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "Enter your family name",
                labelText: "Family",
                errorText: snapshot.error,
              ),
              onChanged: _bloc.changeTenancyName,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        );
      },
    );
  }

  Widget usernameField() {
    return StreamBuilder(
      stream: _bloc.usernameOrEmailAddress,
      builder: (context, snapshot) {
        return PrimaryColorOverride(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
            child: TextField(
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "Enter your username",
                labelText: "Username",
                errorText: snapshot.error,
              ),
              onChanged: _bloc.changeUsernameOrEmailAddress,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        );
      },
    );
  }

  Widget passwordField() {
    return StreamBuilder(
      stream: _bloc.password,
      builder: (context, snapshot) {
        return PrimaryColorOverride(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
            child: TextField(
              maxLines: 1,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Enter your password",
                labelText: "Password",
                errorText: snapshot.error,
              ),
              onChanged: _bloc.changePassword,
            ),
          ),
        );
      },
    );
  }

  Widget submitButton() {
    return StreamBuilder(
      stream: _bloc.submitValid,
      builder: (context, snapshot) {
        return Container(
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
            onPressed: snapshot.hasData ? _bloc.submit : null,
          ),
        );
      },
    );
  }
}
