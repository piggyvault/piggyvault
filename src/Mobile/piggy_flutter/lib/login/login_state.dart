import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginFailure extends LoginState {
  final String errorMessage;

  LoginFailure({required this.errorMessage});

  @override
  String toString() => 'LoginFailure { error: $errorMessage }';

  @override
  List<Object> get props => [errorMessage];
}
