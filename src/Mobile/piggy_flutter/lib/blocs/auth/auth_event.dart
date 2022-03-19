import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final String? token;
  final String tenancyName;

  const LoggedIn({required this.token, required this.tenancyName});

  @override
  List<Object?> get props => [token];
}

class LoggedOut extends AuthEvent {}
