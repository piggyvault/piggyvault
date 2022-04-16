import 'package:equatable/equatable.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class AccountFormEvent extends Equatable {
  const AccountFormEvent();
}

class AccountFormSave extends AccountFormEvent {
  const AccountFormSave({required this.account});

  final AccountFormModel account;

  @override
  List<Object> get props => [account];
}

class AccountFormLoad extends AccountFormEvent {
  const AccountFormLoad({this.accountId});

  final String? accountId;

  @override
  List<Object?> get props => [accountId];
}
