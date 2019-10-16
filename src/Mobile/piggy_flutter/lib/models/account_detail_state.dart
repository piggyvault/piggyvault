import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/models/transactions_result.dart';

class AccountDetailState {
  String title, nextPageTitle, previousPageTitle;
  Account account;

  @override
  String toString() {
    return 'title = $title, nextPageTitle=$nextPageTitle, previousPageTitle=$previousPageTitle, account=$account';
  }
}

class AccountDetailLoading extends AccountDetailState {
  AccountDetailLoading() {
    title = 'This Month';
    nextPageTitle = 'Future';
    previousPageTitle = 'Last Month';
  }
}

class AccountDetailError extends AccountDetailState {}

class AccountDetailEmpty extends AccountDetailState {}

class AccountDetailPopulated extends AccountDetailState {
  final TransactionsResult result;

  AccountDetailPopulated(this.result);
}
