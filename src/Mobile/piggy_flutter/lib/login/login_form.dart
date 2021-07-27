import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/login/login.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:piggy_flutter/widgets/primary_color_override.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tenancyNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _onLoginButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(
        LoginButtonPressed(
          tenancyName: _tenancyNameController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }

    return BlocListener<LoginBloc, LoginState>(listener: (context, state) {
      if (state is LoginFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${state.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }, child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              logo,
              SizedBox(
                height: 30.0,
              ),
              Text(
                "Welcome to ${UIData.appName}",
                style:
                    TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                "Sign in to continue",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          Container(
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
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text(
                      "SIGN IN",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        padding: EdgeInsets.all(12.0),
                        shape: StadiumBorder()),
                    onPressed:
                        state is! LoginLoading ? _onLoginButtonPressed : null,
                  ),
                ),
                Container(
                  child: state is LoginLoading
                      ? CircularProgressIndicator()
                      : null,
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
          )
        ],
      ));
    }));
  }

  final logo = Hero(
    tag: 'hero',
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 48.0,
      child: Image.asset('graphics/logo.png'),
    ),
  );

  Widget familyField() {
    return PrimaryColorOverride(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
        child: TextFormField(
          maxLines: 1,
          controller: _tenancyNameController,
          decoration: InputDecoration(
            hintText: "Enter your family name",
            labelText: "Family",
            // errorText: snapshot.error,
          ),
          // onChanged: _bloc.changeTenancyName,
          keyboardType: TextInputType.emailAddress,
        ),
      ),
    );
  }

  Widget usernameField() {
    return PrimaryColorOverride(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
        child: TextField(
          maxLines: 1,
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: "Enter your username",
            labelText: "Username",
            // errorText: snapshot.error,
          ),
          // onChanged: _bloc.changeUsernameOrEmailAddress,
          keyboardType: TextInputType.emailAddress,
        ),
      ),
    );
  }

  Widget passwordField() {
    return PrimaryColorOverride(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
        child: TextField(
          maxLines: 1,
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Enter your password",
            labelText: "Password",
            // errorText: snapshot.error,
          ),
          // onChanged: _bloc.changePassword,
        ),
      ),
    );
  }
}
