import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:piggy_flutter/models/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserEmpty extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;

  const UserLoaded({@required this.user}) : assert(user != null);

  @override
  String toString() => user.name;

  @override
  List<Object> get props => [user];
}
