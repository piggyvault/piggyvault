import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/login/login.dart';
import 'package:piggy_flutter/login/login_bloc.dart';
import 'package:piggy_flutter/repositories/repositories.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  LoginPage({Key? key, required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
              authBloc: BlocProvider.of<AuthBloc>(context),
              userRepository: userRepository);
        },
        child: LoginForm(),
      ),
    );
  }
}
