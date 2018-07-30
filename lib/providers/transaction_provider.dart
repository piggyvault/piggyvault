import 'package:flutter/material.dart';
import 'package:piggy_flutter/bloc/transaction_bloc.dart';

class TransactionProvider extends InheritedWidget {
  final TransactionBloc transactionBloc;

  TransactionProvider({Key key, TransactionBloc transactionBloc, Widget child})
      : transactionBloc = transactionBloc ?? TransactionBloc(),
        super(key: key, child: child);

  static TransactionBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(TransactionProvider)
            as TransactionProvider)
        .transactionBloc;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
