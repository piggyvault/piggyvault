import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthUninitialized extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated({@required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthLoading extends AuthState {}

// class GettingCurrentLoginInformation extends AuthState {}

// class UserLoggedIn extends AuthState {
//   final User user;

//   const UserLoggedIn({@required this.user}) : assert(user != null);

//   @override
//   List<Object> get props => [user];
// }

// class GettingCurrentLoginInformationError extends AuthState {}
