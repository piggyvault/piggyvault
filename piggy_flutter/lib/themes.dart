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
        headline: base.headline.copyWith(
          fontWeight: FontWeight.w500,
        ),
        title: base.title.copyWith(fontSize: 18.0),
        caption: base.caption.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
      )
      .apply(
          fontFamily: 'GoogleSans',
          displayColor: Colors.black,
          bodyColor: Colors.black);
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
  const Color primaryColor = Colors.white;
  const Color accentColor = Color.fromRGBO(57, 139, 189, 1.0);
  final ThemeData base = new ThemeData.light();
  return base.copyWith(
    accentColor: accentColor,
    primaryColor: primaryColor,
    buttonColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    textSelectionColor: primaryColor,
    errorColor: const Color(0xFFC5032B),
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
