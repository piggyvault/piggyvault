import 'package:equatable/equatable.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [null];
}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  const AccountsLoaded(
      [this.userAccounts = const [], this.familyAccounts = const []]);

  final List<Account>? userAccounts;
  final List<Account>? familyAccounts;

  @override
  List<Object?> get props => [userAccounts, familyAccounts];
}

class AccountsNotLoaded extends AccountsState {}
