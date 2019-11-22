import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:piggy_flutter/dashboard/index.dart';
import 'dart:developer' as developer;

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  // todo: check singleton for logic in project
  static final DashboardBloc _dashboardBlocSingleton = DashboardBloc._internal();
  factory DashboardBloc() {
    return _dashboardBlocSingleton;
  }
  DashboardBloc._internal();
  
  @override
  Future<void> close() async{
    // dispose objects
    super.close();
  }

  DashboardState get initialState => UnDashboardState(0);

  @override
  Stream<DashboardState> mapEventToState(
    DashboardEvent event,
  ) async* {
    try {
      yield await event.applyAsync(currentState: state, bloc: this);
    } catch (_, stackTrace) {
      developer.log('$_', name: 'DashboardBloc', error: _, stackTrace: stackTrace);
      yield state;
    }
  }
}
