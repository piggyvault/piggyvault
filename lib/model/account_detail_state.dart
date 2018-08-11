import 'package:flutter/material.dart';
import 'package:piggy_flutter/model/transactions_result.dart';

class AccountDetailState {
  final String title;
  final String nextPageTitle;
  final String previousPageTitle;

  AccountDetailState(
      {@required this.title,
      @required this.nextPageTitle,
      @required this.previousPageTitle});

  @override
  String toString() {
    return 'title = $title, nextPageTitle=$nextPageTitle, previousPageTitle=$previousPageTitle';
  }
}

class AccountDetailPopulated extends AccountDetailState {
  final TransactionsResult result;

  AccountDetailPopulated(
      {@required this.result,
      @required String title,
      @required String nextPageTitle,
      @required String previousPageTitle})
      : super(
            title: title,
            nextPageTitle: nextPageTitle,
            previousPageTitle: previousPageTitle);
}

class AccountDetailLoading extends AccountDetailState {
  AccountDetailLoading(
      {@required String title,
      @required String nextPageTitle,
      @required String previousPageTitle})
      : super(
            title: title,
            nextPageTitle: nextPageTitle,
            previousPageTitle: previousPageTitle);
}

class AccountDetailError extends AccountDetailState {
  AccountDetailError(
      {@required String title,
      @required String nextPageTitle,
      @required String previousPageTitle})
      : super(
            title: title,
            nextPageTitle: nextPageTitle,
            previousPageTitle: previousPageTitle);
}

class AccountDetailEmpty extends AccountDetailState {
  AccountDetailEmpty(
      {@required String title,
      @required String nextPageTitle,
      @required String previousPageTitle})
      : super(
            title: title,
            nextPageTitle: nextPageTitle,
            previousPageTitle: previousPageTitle);
}
