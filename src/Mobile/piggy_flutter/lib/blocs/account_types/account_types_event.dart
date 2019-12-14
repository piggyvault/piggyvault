import 'package:equatable/equatable.dart';

abstract class AccountTypesEvent extends Equatable {
  const AccountTypesEvent();
}

class AccountTypesLoad extends AccountTypesEvent {
  @override
  List<Object> get props => null;
}
