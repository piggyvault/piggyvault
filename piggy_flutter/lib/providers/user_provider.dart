import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/user_bloc.dart';

class UserProvider extends InheritedWidget {
  final UserBloc userBloc;

  UserProvider({
    Key key,
    UserBloc userBloc,
    Widget child,
  })  : userBloc = userBloc ?? UserBloc(),
        super(key: key, child: child);

  static UserBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(UserProvider) as UserProvider)
        .userBloc;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
