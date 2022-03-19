import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginButtonPressed extends LoginEvent {
  final String tenancyName;
  final String username;
  final String password;

  const LoginButtonPressed(
      {required this.tenancyName,
      required this.username,
      required this.password});

  @override
  List<Object> get props => [tenancyName, username, password];

  @override
  String toString() {
    return 'LoginButtonPressed { username: $tenancyName, username: $username}';
  }
}
