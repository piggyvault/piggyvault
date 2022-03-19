import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/intro_views/Models/page_view_model.dart';
import 'package:piggy_flutter/intro_views/intro_views_flutter.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App widget class

setAccess() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool(UIData.firstAccess, false);
}

class IntroViews extends StatelessWidget {
  IntroViews({Key? key}) : super(key: key);

  //making list of pages needed to pass in IntroViewsFlutter constructor.
  final pages = [
    PageViewModel(
        pageColor: const Color(0xFF03A9F4),
        // iconImageAssetPath: 'assets/air-hostess.png',
        bubble: Image.asset('assets/air-hostess.png'),
        body: Text(
          'If you want to know new places, your savings are the best way to achieve this goal.',
        ),
        title: Text(
          'Travel more',
        ),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        mainImage: Image.asset(
          'assets/airplane.png',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        )),
    PageViewModel(
      pageColor: const Color(0xFF8BC34A),
      // iconImageAssetPath: 'waiter.png',
      body: Text(
        'Stay in comfort, enjoy your savings on beautiful hotels',
      ),
      title: Text('Hotels'),
      mainImage: Image.asset(
        'assets/hotel.png',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
      titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ),
    PageViewModel(
      pageColor: const Color(0xFF607D8B),
      // iconImageAssetPath: '/assets/taxi-driver.png',
      body: Text(
        'Travel without worrying about how much the taxi will be',
      ),
      title: Text('Cabs'),
      mainImage: Image.asset(
        'assets/taxi.png',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
      titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    setAccess();

    return IntroViewsFlutter(
      pages,
      showNextButton: true,
      showBackButton: true,
      onTapDoneButton: () {
        BlocProvider.of<AuthBloc>(context).add(AppStarted());
      },
      pageButtonTextStyles: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
      ),
      //Builder
    ); //Material App
  }
}
