import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  /// notify change state without deep clone state
  final int version;

  final Iterable propss;
  DashboardState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  DashboardState getStateCopy();

  DashboardState getNewVersion();

  @override
  List<Object> get props => (propss);
}

/// UnInitialized
class UnDashboardState extends DashboardState {
  UnDashboardState(version) : super(version);

  @override
  String toString() => 'UnDashboardState';

  @override
  UnDashboardState getStateCopy() {
    return UnDashboardState(0);
  }

  @override
  UnDashboardState getNewVersion() {
    return UnDashboardState(version + 1);
  }
}

/// Initialized
class InDashboardState extends DashboardState {
  final String hello;

  InDashboardState(version, this.hello) : super(version, [hello]);

  @override
  String toString() => 'InDashboardState $hello';

  @override
  InDashboardState getStateCopy() {
    return InDashboardState(this.version, this.hello);
  }

  @override
  InDashboardState getNewVersion() {
    return InDashboardState(version + 1, this.hello);
  }
}

class ErrorDashboardState extends DashboardState {
  final String errorMessage;

  ErrorDashboardState(version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorDashboardState';

  @override
  ErrorDashboardState getStateCopy() {
    return ErrorDashboardState(this.version, this.errorMessage);
  }

  @override
  ErrorDashboardState getNewVersion() {
    return ErrorDashboardState(version + 1, this.errorMessage);
  }
}
