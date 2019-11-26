import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => null;
}

class FetchAccount extends AccountEvent {
  final String accountId;

  FetchAccount({@required this.accountId}) : assert(accountId != null);

  @override
  List<Object> get props => [accountId];
}

class RefreshAccount extends AccountEvent {}
