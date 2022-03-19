import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class AccountState extends Equatable {
  final String? accountId;

  const AccountState(this.accountId);

  @override
  List<Object> get props => [];
}

class AccountEmpty extends AccountState {
  AccountEmpty(String? accountId) : super(accountId);
}

class AccountLoading extends AccountState {
  AccountLoading(String accountId) : super(accountId);
}

class AccountLoaded extends AccountState {
  final Account account;

  AccountLoaded({required this.account}) : super(account.id);
}

class AccountFetchError extends AccountState {
  AccountFetchError(String accountId) : super(accountId);
}
