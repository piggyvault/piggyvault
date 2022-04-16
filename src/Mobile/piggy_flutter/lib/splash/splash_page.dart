import 'package:flutter/material.dart';
import 'package:piggy_flutter/utils/uidata.dart';

class SplashPage extends StatelessWidget {
  static const String routeName = "/splash";

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(UIData.appName),
      ),
    );
  }
}
