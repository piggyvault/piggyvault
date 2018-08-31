import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._(this.name, this.data);

  final String name;
  final ThemeData data;
}

final AppTheme darkAppTheme = new AppTheme._('Dark', _buildDarkTheme());
final AppTheme lightAppTheme = new AppTheme._('Light', _buildLightTheme());

TextTheme _buildTextTheme(TextTheme base) {
  return base
      .copyWith(
        title: base.title.copyWith(
          fontFamily: 'GoogleSans',
        ),
      )
      .apply(displayColor: Colors.black, bodyColor: Colors.black);
}

ThemeData _buildDarkTheme() {
  const Color primaryColor = Color(0xFF0175c2);
  final ThemeData base = new ThemeData.dark();
  return base.copyWith(
    primaryColor: primaryColor,
    buttonColor: primaryColor,
    indicatorColor: Colors.white,
    accentColor: const Color(0xFF13B9FD),
    canvasColor: const Color(0xFF202124),
    scaffoldBackgroundColor: const Color(0xFF202124),
    backgroundColor: const Color(0xFF202124),
    errorColor: const Color(0xFFB00020),
    buttonTheme: const ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
  );
}

_buildIconTheme(IconThemeData base) {
  return base.copyWith(
    color: Colors.black,
  );
}

ThemeData _buildLightTheme() {
  // const Color primaryColor = Color.fromRGBO(118, 53, 235, 1.0);
  const Color primaryColor = Colors.white;
  final ThemeData base = new ThemeData.light();
  return base.copyWith(
    primaryColor: primaryColor,
    buttonColor: primaryColor,
    // indicatorColor: Colors.white,
    indicatorColor: Colors.black,
    splashColor: Colors.white24,
    splashFactory: InkRipple.splashFactory,
    // accentColor: const Color(0xFF13B9FD),
    // accentColor: const Color.fromRGBO(118, 53, 235, 1.0),
    accentColor: const Color.fromRGBO(57, 139, 189, 1.0),
    // accentColor: Colors.cyan[600],
    canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: Colors.white,
    errorColor: const Color(0xFFB00020),
    buttonTheme: const ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
    iconTheme: _buildIconTheme(base.iconTheme),
    primaryIconTheme: _buildIconTheme(base.primaryIconTheme),
    accentIconTheme: _buildIconTheme(base.accentIconTheme),
  );
}
