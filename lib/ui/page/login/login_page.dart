import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/user_bloc.dart';
import 'package:piggy_flutter/ui/page/home/home.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final UserBloc _userBloc = new UserBloc();

  @override
  void initState() {
    super.initState();
    _userBloc.isAuthenticated.listen(onLoginResult);
    authCheck();
  }

  void authCheck() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(UIData.authToken);
    if (token != null && token.length > 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
                isInitialLoading: true,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: loginBody(_userBloc),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  loginBody(UserBloc userBloc) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[loginHeader(userBloc), loginFields(userBloc)],
      );

  loginHeader(UserBloc userBloc) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // FlutterLogo(
          //   colors: Colors.green,
          //   size: 80.0,
          // ),
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
          subHeading(userBloc),
        ],
      );

  loginFields(UserBloc userBloc) => Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            familyField(userBloc),
            usernameField(userBloc),
            passwordField(userBloc),
            SizedBox(
              height: 30.0,
            ),
            submitButton(userBloc),
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

  Widget subHeading(UserBloc userBloc) {
    return StreamBuilder(
      stream: userBloc.isAuthenticating,
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data) {
          return Text(
            "Sign in to continue",
            style: TextStyle(color: Colors.grey),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget familyField(UserBloc userBloc) {
    return StreamBuilder(
      stream: userBloc.tenancyName,
      builder: (context, snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
          child: TextField(
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "Enter your family name",
              labelText: "Family",
              errorText: snapshot.error,
            ),
            onChanged: userBloc.changeTenancyName,
            keyboardType: TextInputType.emailAddress,
          ),
        );
      },
    );
  }

  Widget usernameField(UserBloc userBloc) {
    return StreamBuilder(
      stream: userBloc.usernameOrEmailAddress,
      builder: (context, snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          child: TextField(
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "Enter your username",
              labelText: "Username",
              errorText: snapshot.error,
            ),
            onChanged: userBloc.changeUsernameOrEmailAddress,
            keyboardType: TextInputType.emailAddress,
          ),
        );
      },
    );
  }

  Widget passwordField(UserBloc userBloc) {
    return StreamBuilder(
      stream: userBloc.password,
      builder: (context, snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          child: TextField(
            maxLines: 1,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Enter your password",
              labelText: "Password",
              errorText: snapshot.error,
            ),
            onChanged: userBloc.changePassword,
          ),
        );
      },
    );
  }

  Widget submitButton(UserBloc userBloc) {
    return StreamBuilder(
      stream: userBloc.submitValid,
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
            onPressed: snapshot.hasData ? userBloc.submit : null,
          ),
        );
      },
    );
  }

  onLoginResult(bool isAuthenticated) {
    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  isInitialLoading: true,
                )),
      );
    } else {
      _scaffoldKey.currentState?.showSnackBar(
        new SnackBar(
          backgroundColor: Colors.red,
          content: const Text(
              'Something went wrong, check the credentials and try again.'),
        ),
      );
    }
  }
}
