import 'package:equatable/equatable.dart';
import 'package:piggy_flutter/models/account_form_model.dart';

abstract class AccountFormState extends Equatable {
  const AccountFormState();

  @override
  List<Object?> get props => [null];
}

class InitialAccountFormState extends AccountFormState {}

class AccountFormLoading extends AccountFormState {}

class AccountFormLoaded extends AccountFormState {
  const AccountFormLoaded({required this.account});

  final AccountFormModel? account;

  @override
  List<Object?> get props => [account];
}

class AccountFormSaving extends AccountFormState {}

class AccountFormSaved extends AccountFormState {}

class AccountFormError extends AccountFormState {}
