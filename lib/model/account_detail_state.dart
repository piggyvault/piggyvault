import 'package:piggy_flutter/model/transactions_result.dart';

class AccountDetailState {
  final String title;

  AccountDetailState(this.title);
}

class AccountDetailPopulated extends AccountDetailState {
  final TransactionsResult result;

  AccountDetailPopulated({this.result, String title}) : super(title);
}

class AccountDetailLoading extends AccountDetailState {
  AccountDetailLoading(String title) : super(title);
}

class AccountDetailError extends AccountDetailState {
  AccountDetailError(String title) : super(title);
}

class AccountDetailEmpty extends AccountDetailState {
  AccountDetailEmpty(String title) : super(title);
}
