import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthUninitialized extends AuthState {}

class AuthAuthenticated extends AuthState {
  AuthAuthenticated({required this.user, required this.tenant});

  final User? user;
  final Tenant? tenant;

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class FirstAccess extends AuthState {}

class AuthLoading extends AuthState {}
