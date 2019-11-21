import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/auth/auth_bloc.dart';
import 'package:piggy_flutter/login/login.dart';
import 'package:piggy_flutter/login/login_bloc.dart';
import 'package:piggy_flutter/repositories/repositories.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: BlocProvider(
          builder: (context) {
            return LoginBloc(
                authBloc: BlocProvider.of<AuthBloc>(context),
                userRepository: userRepository);
          },
          child: LoginForm(),
        ));
  }
}

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   LoginBloc _bloc;
//   StreamSubscription _apiSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _bloc = LoginBloc();

//     _apiSubscription = apiSubscription(
//         stream: _bloc.state, context: context, key: _scaffoldKey);
//     authCheck();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Colors.white,
//       body: Center(
//         child: LoginForm(),
//       ),
//     );
//   }

//   @override
//   dispose() {
//     _bloc?.dispose();
//     _apiSubscription?.cancel();
//     super.dispose();
//   }

//   void authCheck() async {
//     final prefs = await SharedPreferences.getInstance();

//     var token = prefs.getString(UIData.authToken);
//     var firstAccess = prefs.getBool(UIData.firstAccess) ?? true;

//     if (token != null && token.length > 0 && !firstAccess) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomePage(
//             isInitialLoading: true,
//           ),
//         ),
//       );
//     } else {
//       if (firstAccess)
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => IntroViews(),
//           ),
//         );
//     }
//   }
// }
