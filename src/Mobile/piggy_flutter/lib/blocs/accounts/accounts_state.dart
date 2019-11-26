import 'package:equatable/equatable.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object> get props => ([]);
}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  final List<Account> userAccounts;
  final List<Account> familyAccounts;

  const AccountsLoaded(
      [this.userAccounts = const [], this.familyAccounts = const []]);

  @override
  List<Object> get props => [userAccounts, familyAccounts];
}

class AccountsNotLoaded extends AccountsState {}
