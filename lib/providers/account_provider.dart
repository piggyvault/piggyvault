import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/account_bloc.dart';

class AccountProvider extends InheritedWidget {
  final AccountBloc accountBloc;

  AccountProvider({
    Key key,
    AccountBloc accountBloc,
    Widget child,
  })  : accountBloc = accountBloc ?? AccountBloc(),
        super(key: key, child: child);

  static AccountBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(AccountProvider)
            as AccountProvider)
        .accountBloc;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
