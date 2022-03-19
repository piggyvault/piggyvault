import 'package:equatable/equatable.dart';

abstract class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [null];
}

class LoadAccounts extends AccountsEvent {}
