import 'package:bloc/bloc.dart';
import 'package:piggy_flutter/user/user.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  @override
  UserState get initialState => UserEmpty();

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is UserLoggedIn) {
      yield UserLoaded(user: event.user);
    }

    if (event is UserLoggedOut) {
      yield UserEmpty();
    }
  }
}
