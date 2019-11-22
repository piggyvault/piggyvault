import 'dart:async';
import 'package:piggy_flutter/dashboard/index.dart';
import 'package:meta/meta.dart';
import 'dart:developer' as developer;

@immutable
abstract class DashboardEvent {
  Future<DashboardState> applyAsync(
      {DashboardState currentState, DashboardBloc bloc});
}

class UnDashboardEvent extends DashboardEvent {
  @override
  Future<DashboardState> applyAsync(
      {DashboardState currentState, DashboardBloc bloc}) async {
    return UnDashboardState(0);
  }
}

class LoadDashboardEvent extends DashboardEvent {
  final bool isError;
  @override
  String toString() => 'LoadDashboardEvent';

  LoadDashboardEvent(this.isError);

  @override
  Future<DashboardState> applyAsync(
      {DashboardState currentState, DashboardBloc bloc}) async {
    try {
      if (currentState is InDashboardState) {
        return currentState.getNewVersion();
      }
      // await Future.delayed(Duration(seconds: 2));
      // this._dashboardRepository.test(this.isError);
      return InDashboardState(0, "Hello world");
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadDashboardEvent', error: _, stackTrace: stackTrace);
      return ErrorDashboardState(0, _?.toString());
    }
  }
}
