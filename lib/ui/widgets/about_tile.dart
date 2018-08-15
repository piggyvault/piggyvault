import 'package:flutter/material.dart';
import 'package:piggy_flutter/utils/uidata.dart';

class MyAboutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AboutListTile(
      applicationIcon: FlutterLogo(
        colors: Colors.yellow,
      ),
      icon: Icon(Icons.info_outline),
      aboutBoxChildren: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Text(
          "Developed By Abhith Rajan",
        ),
        Text(
          "@AbhithRajan ",
        ),
      ],
      applicationName: UIData.appName,
      applicationVersion: UIData.appVersion,
      applicationLegalese: "Apache License 2.0",
    );
  }
}