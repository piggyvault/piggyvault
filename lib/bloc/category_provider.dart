import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/category_bloc.dart';

class CategoryProvider extends InheritedWidget {
  final CategoryBloc categoryBloc;

  CategoryProvider({
    Key key,
    CategoryBloc categoryBloc,
    Widget child,
  })  : categoryBloc = categoryBloc ?? CategoryBloc(),
        super(key: key, child: child);

  static CategoryBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(CategoryProvider)
            as CategoryProvider)
        .categoryBloc;


  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
